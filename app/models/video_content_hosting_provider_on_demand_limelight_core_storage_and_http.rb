require 'net/ftp'
class VideoContentHostingProviderOnDemandLimelightCoreStorageAndHttp < VideoContentHostingProviderOnDemand

	ffma_create_attribute 'configuration', 'origin_ftp_username', :string
	ffma_create_attribute 'configuration', 'origin_ftp_password', :string
	ffma_create_attribute 'configuration', 'origin_ftp_host', :string
	ffma_create_attribute 'configuration', 'origin_ftp_port', :integer, 21
	ffma_create_attribute 'configuration', 'origin_ftp_host_path', :string, '/'

	ffma_create_attribute 'configuration', 'download_flash_host', :string
	ffma_create_attribute 'configuration', 'download_flash_application_name', :string
	ffma_create_attribute 'configuration', 'download_flash_path_prefix', :string
	ffma_create_attribute 'configuration', 'download_http_host', :string
	ffma_create_attribute 'configuration', 'download_http_application_name', :string
	ffma_create_attribute 'configuration', 'download_http_path_prefix', :string

	ffma_create_attribute 'configuration', 'media_vault_enable', :bool, true
	ffma_create_attribute 'configuration', 'media_vault_secret', :string
	ffma_create_attribute 'configuration', 'media_vault_uri_base', :string

	ffma_create_attribute 'configuration', 'media_vault_security_enforce_time', :bool, true
	ffma_create_attribute 'configuration', 'media_vault_security_time_interval_in_seconds', :integer, 300
	# Allows us to set the start time back a few & forward seconds/minutes to account for server clock drift/skew
	ffma_create_attribute 'configuration', 'media_vault_security_time_clock_skew_in_seconds', :integer, 120


	ffma_create_attribute 'configuration', 'storage_folder_max_name_length', :integer, 3 # folders limited to 3 characters, must be > 0
	ffma_create_attribute 'configuration', 'storage_folder_max_depth', :integer, 2 # 2 folders maximum, -1 = no limit, 0 means store file name with no directories





	validates_presence_of 'origin_ftp_username'
	validates_presence_of 'origin_ftp_password'
	validates_presence_of 'origin_ftp_host'
	validates_format_of 'origin_ftp_host', :with => /\A[a-z0-9\-\.]+\Z/i
	validates_length_of 'origin_ftp_host', :in => 4..255
	validates_presence_of 'origin_ftp_host_path'
	validates_format_of 'origin_ftp_host_path', :with => /\A\/.*\Z/i

	validates_presence_of 'media_vault_secret', :if => :use_media_vault?
	validates_length_of 'media_vault_secret', :in => 10..64, :if => :use_media_vault?

	validates_presence_of 'media_vault_security_time_interval_in_seconds', :if => :media_vault_security_enforce_time
	validates_presence_of 'media_vault_security_time_clock_skew_in_seconds', :if => :media_vault_security_enforce_time
	validates_numericality_of 'media_vault_security_time_interval_in_seconds', :only_integer => true, :greater_than => 0, :if => :media_vault_security_enforce_time
	validates_numericality_of 'media_vault_security_time_interval_in_seconds', :only_integer => true, :greater_than_or_equal => 0, :if => :media_vault_security_enforce_time

	validates_presence_of 'download_flash_host'
	validates_format_of 'download_flash_host', :with => /\A[a-z0-9\-\.]+\Z/i
	validates_length_of 'download_flash_host', :in => 4..255

	validates_presence_of 'download_http_host'
	validates_format_of 'download_http_host', :with => /\A[a-z0-9\-\.]+\Z/i
	validates_length_of 'download_http_host', :in => 4..255

	validates_presence_of 'download_flash_application_name'
	validates_length_of 'download_flash_application_name', :in => 1..255
	validates_format_of 'download_flash_application_name', :with => /\A\/[a-z0-9\-_\/\.]+[a-z0-9_\-\.]\Z/i

	validates_presence_of 'download_http_application_name'
	validates_length_of 'download_http_application_name', :in => 1..255
	validates_format_of 'download_http_application_name', :with => /\A\/[a-z0-9_\-\/\.]+[a-z0-9_\-\.]\Z/i



	validates_presence_of 'storage_folder_max_depth'
	# 0 means no max depth, keep breaking up file name every max_name_length
	validates_numericality_of 'storage_folder_max_depth', :only_integer => true, :greater_than_or_equal => -1

	validates_presence_of 'storage_folder_max_name_length'
	# 0 means no max name length, files stored in root folder as the given filename
	validates_numericality_of 'storage_folder_max_name_length', :only_integer => true, :greater_than => 0




	def use_media_vault?
		self.media_vault_enable
	end

	def origin_ftp_host_and_port
		ret = self.origin_ftp_host
		ret += ':' + self.origin_ftp_port.to_s unless self.origin_ftp_port.eql?(21)
		ret
	end

	def ftp_uri
		ret = 'ftp://' + self.origin_ftp_username + '@' + origin_ftp_host_and_port + self.origin_ftp_host_path
	end

	def flash_uri
		ret = 'rtmpt://' + self.download_flash_host + ( Pathname.new(self.download_flash_application_name) + Pathname.new(self.download_flash_path_prefix || '') ).to_s
	end

	def http_uri
		ret = 'http://' + self.download_http_host + ( Pathname.new(self.download_http_application_name) + Pathname.new(self.download_http_path_prefix || '') ).to_s
	end

	def content_model_name
		'VideoContentHostedOnDemandLimelightCoreStorageAndHttp'
	end


### Ready for upload Callback
#
# Informs (usually the video content being created and uploaded) the hosting provider model that the video content is ready for upload. A VideoContent record exists and file is uploaded to the temporary store. Subclasses should arrange to upload the video to the CDN
#
# @param[in] video_content The video content that is ready for upload
# @return return value is ignored
	def video_content_ready_for_upload( video_content )
		# schedule an upload
		CDNLimelightCoreStorageUploadVideoContentFileTask.make_task( video_content )
	end

### Video Content Removed Callback
#
# Informs (usually the video content getting deleted) the hosting provider model that the video content has been removed (destroyed or deleted). A VideoContent record no longer exists and file is no longer at the temporary store. Subclasses should arrange to remove the video from the CDN
#
# @param[in] video_content The video content that is ready for upload
# @return return value is ignored
	def video_content_removed( video_content )
		# schedule an upload
		CDNLimelightCoreStorageRemoveVideoContentFileTask.make_task( video_content )
	end


### Delete file
#
# Deletes one file from the CDN immediately, no callbacks are called. While it would be nice to have the video_content record, by this point, it's usually been deleted from the database.
#
# @param[in] file_info The information required to accurately identify the file to be removed. This is highly dependend on the CDN and, by extension, the subclass implementor. The file details should be a hash of the required information, the minimum information required is: { :file_md5_hash => STR, :file_extension => STR }
# @returns True if file is no longer at the CDN, false if it's still there, for whatever reason
	def delete_from_provider( file_info = {} )
		ret = false
		ftp_open do |ftp|
			path_array = file_hash_and_extension_to_array( file_info[:file_md5_hash], file_info[:file_extension] )
			ret = self.class.delete_from_provider( ftp, path_array )
		end
		ret = true
	end

### Delete from Provider
#
# Port of the older implementation, but is a class method to allow deletion without classful knowledge. Used by the class method to delete a file. This also will clean up the provider's folder structure for empty folders. This is done because folders take up inodes and thus, space that the client is paying for.
#
# @param[in] ftp A handle to the open Net::FTP connection object, ready to go to work and set to the of the hosting path (the folder into which you want sub folders and files placed). 
# @param[in] file_path_as_array An array containing each component of the file's path as it exists on the provider's systems. The last (or only) element in the array is assumed to be the filename, with extension, if any. The array passed to this parameter is always expected to have at least 1 element. It is an argument error if this is not the case
#
# @raises FTPReplyError
# @raises FTPPermError if the file cannot be deleted or navigated to due to lack of permissions
#
# @returns nothing, if it returns, it means that no errors encountered. If it raises an error for any reason, it did not complete it's task of deleting the file
	def self.delete_from_provider( ftp, file_path_as_array )
		raise ArugmentError.new "file_path_as_array requries at least 1 parameter (a file name with extension, if requried)" if file_path_as_array.size < 1
		raise ArgumentError.new "FTP connection was closed. Make sure it's opened" if ftp.closed?
		# delete the file
		ret = ftp.delete( file_path_as_array.join('/') )
		# Path has only 1 element, it IS the file
		unless file_path_as_array.size.eql?(1)
			# File is now deleted, let's clean up the provider's folder storage
			recursively_delete_empty_directories( ftp, file_path_as_array[0..-2] )
		end
		return ret
	end

### Upload file
#
# "puts" one file to the CDN immediately, no callbacks are called
#
# @param[in] file_info The information required to upload the file. It should include the minimum: { :absolute_local_file_path => STR,  }
	def upload_to_provider( file_info = {} )
		ret = false
		ftp_open do |ftp|
			remote_path_array = file_hash_and_extension_to_array( file_info[:file_md5_hash], file_info[:file_extension] )
			ret = self.class.upload_to_provider( ftp, file_info[:file_local_path], remote_path_array )
		end
		ret
	end

### Upload to Provider
#
# Uploads a file specified by the local path to the remote_path_array, complete with filename and extension
#
# @param[in] ftp The FTP connection, ready and opened to the hosted file root path (the base where all files and folders live)
# @param[in] file_local_path String pointing to the relative or absolute path to the file that is to be uploaded to the provider. This file MUST exist
#
# @raises FTPReplyError with a message about being unable to create a directory remotely if it is not able to build the requested path
#
# @return nothing. If it returns, all was a success. If it throws an error, something went wrong
	def self.upload_to_provider( ftp, file_local_path, remote_path_array )
		raise ArgumentError.new "Local file: \"#{file_local_path}\" does not exists. I can't upload something I cannot find" unless File.exists?( file_local_path )
		raise ArgumentError.new "FTP connection was closed. Make sure it's opened" if ftp.closed?

		# We now need to traverse to the destination folder on the remote side, creating folders as required
		# Skip this process if no folders need be created:
		unless remote_path_array.size.eql?(1)
			# Create folders based on the remote_path_array. Don't include the file and extension (last element in array)
			p = remote_path_array[0..-2]
			builder = [p.first]
			# Loop until we're at the last folder
			current_path = nil
			begin
				until builder.size.eql?(p.size)
					current_path = builder.join('/')
					unless ftp_directory_exists?( ftp, current_path )
						ftp.mkdir( current_path )
					end
					# adds the next path component to the builder array. If builder has 2 elements, it's size will be 2. This means that p's 3rd element p[2] will be pulled in next
					builder << p[builder.size]
				end
				# also covers the case where there is a single directory as they won't be created above
				# This is the end-post case
				current_path = builder.join('/')
				unless ftp_directory_exists?( ftp, current_path )
					ftp.mkdir( builder.join('/') )
				end

				# Actually put the file up
				ftp.put( file_local_path, remote_path_array.join('/') )
			rescue Net::FTPReplyError => e
				raise Net::FTPReplyError.new "Unable to create directory: \"#{ftp.pwd}/#{builder.join('/')}\""
			end
			return true
		else
			return false
		end
	end

### Synchronize local to provider
#
# Updates the provider store with all the local files. This, of course, assumes that the local files still exist on the local drive. In addition, any extra files at the CDN will be removed.
#
# @return { :total_files => N, :files_deleted => N, :files_uploaded => N }
	def synchronize_local_to_provider
		raise NotImplementedError.new
	end


### Synchronize provider to local
#
# Updates the local store with all the provider files. This, of course, assumes that the provider files still exist on the provider store. In addition, any extra files on the local drive will be removed.
#
# @return { :total_files => N, :files_deleted => N, :files_downloaded => N }
	def synchronize_provider_to_local
		raise NotImplementedError.new
	end

### Synchronize Non-destructively
#
# Copies all files that do not exist locally from the provider to the local store. Then copies all files from the local store to the provider that do not exists at the provider. No files are deleted.
#
# @return { :files_uploaded => N, :files_downloaded => N }
	def synchronize
		raise NotImplementedError.new
	end

### Check to see if this file is uploaded to the CDN
#
# @param[in] video_content the video content record that corresponds to the file you want to check exists @ the CDN. Record must exist
# @return true if it's been published to the CDN, false if not
	def exists?( video_content )
		ftp_open do |ftp|
			return self.class.ftp_file_exists?( ftp, file_hash_and_extension_to_array( video_content.file_hash, video_content.file_extension ).join('/') )
		end
	end



### Create FTP Connection
# Creates a Net::FTP object, connects, and logs in based on the information in the model
# @returns Net::FTP object fully created, connected, and logged in as indicated by the configuration['origin_ftp_*'] settings
	def create_ftp_connection
		ftp = Net::FTP.new()
		ftp.connect( self.origin_ftp_host, self.origin_ftp_port )
		ftp.login( self.origin_ftp_username, self.origin_ftp_password )
		ftp
	end

### FTP Open Connection
#
# Wraps FTP creation and close as a convenience so that we never forget to close the FTP connection, ever. Also opens the connection to the prefix path as configured by the VMS administrator
#
# @params[in] block The Proc or block to call once the connection is established. The FTP connection object: Net::FTP is passed as the argument.
# @return nil, always
	def ftp_open( &block )
		ftp_connection = create_ftp_connection
		ftp_connection.chdir( ftp_host_path )
		yield( ftp_connection )
		ftp_connection.close
		nil
	end

### FTP Hosting Path
#
# Produces the absolute path for the hosted files.
#
# @param[in] append A string or Pathname to append to the end of the hosting path. Useful for building CD paths and then moving to them
# @returns The absolute path (pass directly to Net::FTP.chdir, if you like) of the root of where the files are, with the parameter (if supplied) appended to the end of the root hosting path
	def ftp_host_path( append = nil )
		r = '/' + self.origin_ftp_host_path
		r += '/' + append.to_s unless append.nil?
		r
	end


### Convert File hash to Split Array
#
# Takes a file hash (or any string, really), and cuts it into an array with 1 or more elements based on the arguments
#
# @param[in] s The string to chop into a pathname
# @param[in] max_num_dirs The number of directories to chop the hash into. If -1 is specified, then the number of directories is limited to the number of characters in the string provided (effectively ignores the number of directories to be made and bases the decision completely on the dir_name_length split process. If the number of directories requested cannot be fulfilled, then it will attempt to create as many as possible, instead. It uses dir_name_length to chop the path into directories with names of that size
# @param[in] max_dir_name_length the maximum number of characters that can appear in a directory name. For example, if this is 4 and the max_num_dirs is 0, then the input string, s, is chopped up into a pathname that contains the string, s, but split into a directory every 4 characters. If max_num_dirs is non-zero, then it will split up the string to path names until the specified number of directories is reached. For example, if s = 'abcdefghijklmnop', max_num_dirs = 2, and max_dir_name_length = 2, then the result is: Pathname{'/ab/cd/efghijklmnop'}.
# @returns Array containing the given path, s, split according to the limitations set by the arguments
	def self.file_hash_to_split_array( s, max_num_dirs, max_dir_name_len )
		ret = []
		s = s.dup
		raise ArgumentError.new "max_dir_name_len must be > 0" if max_dir_name_len <= 0
		dir_rounds = 0
		while dir_rounds < max_num_dirs or max_num_dirs.eql?(-1)
			l = s.slice!( 0...max_dir_name_len )
			break if l.empty? # nothing left to split, return
			ret << l
			dir_rounds += 1
		end
		ret << s unless s.empty?
		return ret
	end

### Convert file hash and extension to path array
#
# Given a file hash and file extension (if any), creates an array with the hash split into directory componenets as configured by this provider (in the provider's settings)
#
# @param[in] h The file's hash
# @param[in] ext The file's extension. This is optional. If not given (or is nil), will not append an extension
# @return array with each component split accoring to the settings in this provider and as determined by self.file_hash_to_split_array
	def file_hash_and_extension_to_array( h, ext = nil )
		r = self.class.file_hash_to_split_array( h, self.storage_folder_max_depth, self.storage_folder_max_name_length )
		r[r.size - 1] = r.last + '.' + ext unless ext.nil?
		r
	end

### Recursively delete empty directories
#
# Deletes the given folder path starting with the longest path and sequentially popping the array until no more are left or can be deleted
#
# @param[in] ftp The FTP connection with the pwd set to the hosted files path (where the subfolders given in path_as_array live)
# @param[in] path_as_array An array containing ONLY directory names. Do not include the filename or filename with extension. Each directory will be reviewed starting with the greatest depth, and deleted one at a time until they're all deleted or can no longer be deleted
# @return true
	def self.recursively_delete_empty_directories( ftp, path_as_array )
		path_as_array = path_as_array.dup
		until path_as_array.empty?
			begin
				ftp.rmdir( path_as_array.join('/') )
			rescue Net::FTPReplyError => e
				# Cannot delete this folder, quit
				return true
			end
			path_as_array.pop
		end
		return true
	end


### FTP Remote Directory Exists
#
# Tests if a remote directory exists
#
# @param[in] ftp The open and ready FTP connection with pwd to the hosted file root (where the files live)
# @param[in] path String to the path to test
#
# @returns true if the path exists, false if it does not
	def self.ftp_directory_exists?( ftp, path )
		# first, save the current directory, we'll need to go back to if if we succeed
		cwd = ftp.pwd
		begin
			ftp.chdir( path )
		rescue Net::FTPPermError => e
			# no such file, no need to reset the pwd as we didn't CD as the folder didn't exist
			return false
		end
		# go back to the original folder
		ftp.chdir( cwd )
		return true
	end


### FTP Remote File Exists
#
# Tests if a remote file exists
#
# @param[in] ftp The open and ready FTP connection with pwd to the hosted file root (where the files live)
# @param[in] path String to the path to test
#
# @returns true if the path exists, false if it does not
	def self.ftp_file_exists?( ftp, path )
		begin
			ftp.size( path )
		rescue Net::FTPPermError => e
			return false
		end
		return true
	end

end
