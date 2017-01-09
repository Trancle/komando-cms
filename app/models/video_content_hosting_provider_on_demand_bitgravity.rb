require 'net/ftp'
class VideoContentHostingProviderOnDemandBitgravity < VideoContentHostingProviderOnDemand

  ffma_create_attribute 'configuration', 'origin_ftp_username', :string
	ffma_create_attribute 'configuration', 'origin_ftp_password', :string
	ffma_create_attribute 'configuration', 'origin_ftp_host', :string
	ffma_create_attribute 'configuration', 'origin_ftp_path_prefix', :string, '/mms'

	ffma_create_attribute 'configuration', 'download_http_host', :string
  ffma_create_attribute 'configuration', 'company_id', :string

  ffma_create_attribute 'configuration', 'secure', :bool, true
  ffma_create_attribute 'configuration', 'protect_secret', :string
  ffma_create_attribute 'configuration', 'protect_path_prefix', :string, '/secure'

	ffma_create_attribute 'configuration', 'protect_enforce_time', :bool, true
	ffma_create_attribute 'configuration', 'protect_time_interval_in_seconds', :integer, 300
	# Allows us to set the start time back a few & forward seconds/minutes to account for server clock drift/skew
	ffma_create_attribute 'configuration', 'protect_time_clock_skew_in_seconds', :integer, 120





	validates_presence_of 'origin_ftp_username'
	validates_presence_of 'origin_ftp_password'
  validates_presence_of 'company_id'
	validates_presence_of 'origin_ftp_host'
	validates_format_of 'origin_ftp_host', :with => /\A[a-z0-9\-\.]+\Z/i
	validates_length_of 'origin_ftp_host', :in => 4..255
	validates_presence_of 'origin_ftp_path_prefix'
	validates_format_of 'origin_ftp_path_prefix', :with => /\A\/(.+[^\/]\Z|\Z)/i # start with a /, but don't end with a slash

	validates_presence_of 'protect_secret', :if => :secure?
	validates_length_of 'protect_secret', :in => 10..64, :if => :secure?


  validates_presence_of 'protect_path_prefix', :if => :secure?
  validates_length_of 'protect_path_prefix', :in => 1..64, :if => :secure?

	validates_presence_of 'protect_time_interval_in_seconds', :if => :protect_enforce_time
	validates_presence_of 'protect_time_clock_skew_in_seconds', :if => :protect_enforce_time
	validates_numericality_of 'protect_time_interval_in_seconds', :only_integer => true, :greater_than => 0, :if => :protect_enforce_time
	validates_numericality_of 'protect_time_interval_in_seconds', :only_integer => true, :greater_than_or_equal => 0, :if => :protect_enforce_time

	validates_presence_of 'download_http_host'
	validates_format_of 'download_http_host', :with => /\A[a-z0-9\-\.]+\Z/i
	validates_length_of 'download_http_host', :in => 4..255


  @@bitgravity_ftp_timeout = 60


	def secure?
		self.secure
	end

	def content_model_name
		'VideoContentHostedOnDemandBitgravity'
	end


### Ready for upload Callback
#
# Informs (usually the video content being created and uploaded) the hosting provider model that the video content is ready for upload. A VideoContent record exists and file is uploaded to the temporary store. Subclasses should arrange to upload the video to the CDN
#
# @param[in] video_content The video content that is ready for upload
# @return return value is ignored
	def video_content_ready_for_upload( video_content )
		# schedule an upload
		UploadVideoContentFileBitgravityTask.make_task( video_content )
	end

### Video Content Removed Callback
#
# Informs (usually the video content getting deleted) the hosting provider model that the video content has been removed (destroyed or deleted). A VideoContent record no longer exists and file is no longer at the temporary store. Subclasses should arrange to remove the video from the CDN
#
# @param[in] video_content The video content that is ready for upload
# @return return value is ignored
	def video_content_removed( video_content )
		# schedule an upload
		RemoveVideoContentFileBitgravityTask.make_task( video_content )
	end


### Delete file
#
# Deletes one file from the CDN immediately, no callbacks are called. While it would be nice to have the video_content record, by this point, it's usually been deleted from the database.
#
# @param[in] file_info The information required to accurately identify the file to be removed. This is highly dependend on the CDN and, by extension, the subclass implementor. The file details should be a hash of the required information, the minimum information required is: { :file_md5_hash => STR, :file_extension => STR }
# @returns True if file is no longer at the CDN, false if it's still there, for whatever reason
	def delete_from_provider( file_info = {} )
    r = false
    Timeout::timeout(@@bitgravity_ftp_timeout) do
      ftp = BitGravity::Ftp.new(self.origin_ftp_host,self.origin_ftp_username,self.origin_ftp_password)
      r = ftp.remove_file_and_clean_directories( path( file_info[:file_md5_hash], file_info[:file_extension] ) )
      ftp.close
    end
    r
	end

### Upload file
#
# "puts" one file to the CDN immediately, no callbacks are called
#
# @param[in] file_info The information required to upload the file. It should include the minimum: { :file_local_path => PATH_TO_FILE_TO_UPLOAD, :file_md5_hash => HASH_OF_FILE_TO_BE_UPLOADED, :file_extension => EXTENSION_OF_FILE_TO_UPLOAD }
	def upload_to_provider( file_info = {} )
    l = File.open("#{RAILS_ROOT}/log/upload.log",'a+')
    r = false
    # we don't want to set a timeout that's too low on this
    Timeout::timeout(3600*4) do # 4-hour timeout: nobody should be uploading longer than 4 hours
      ftp = BitGravity::Ftp.new(self.origin_ftp_host,self.origin_ftp_username,self.origin_ftp_password)
      l << "#{Time.now.strftime("%Y-%m-%dT%H:%M:%s")}: Starting upload of #{file_info[:file_local_path]}\n"
      r = ftp.upload( file_info[:file_local_path], path( file_info[:file_md5_hash], file_info[:file_extension] ) )
      l << "#{Time.now.strftime("%Y-%m-%dT%H:%M:%s")}: Upload of #{file_info[:file_local_path]} complete. Closing connection\n"
      ftp.close
    end
    l.close
    r
	end

### Check to see if this file is uploaded to the CDN
#
# @param[in] video_content the video content record that corresponds to the file you want to check exists @ the CDN. Record must exist
# @return true if it's been published to the CDN, false if not
	def exists?( video_content )
    r = false
   Timeout::timeout(@@bitgravity_ftp_timeout) do
      ftp = BitGravity::Ftp.new(self.origin_ftp_host,self.origin_ftp_username,self.origin_ftp_password)
      r = ftp.exists?( path( video_content.file_hash, video_content.file_extension ) )
      ftp.close
    end
    r
  end



=begin
hash: File hash
ext: file extension
opts: the bitgravity URL parameters

Also for opts:
  expires_in: [Number] of seconds to add to the present UTC time to allow the file to be downloaded. This is just for convenience.
=end
  def http_uri( hash, ext, opts = {} )
    if opts[:e].nil?
      # we must have an expiration for protected content
      if self.protect_enforce_time
        opts[:e] = Time.now.utc.to_i + self.protect_time_interval_in_seconds + self.protect_time_clock_skew_in_seconds
      else
        #
        if opts[:expires_in]
          opts[:e] = Time.now.utc.to_i + opts[:expires_in] + self.protect_time_clock_skew_in_seconds
        else
          # set the default to a year. We must have an expiration date
          opts[:e] = Time.now.utc.to_i + 10.year
        end

      end
    end
    opts.delete(:expires_in)

    BitGravity::SecureUrl.new( self.protect_secret, self.download_http_host, self.company_id, [self.protect_path_prefix] ).url( self.path( hash, ext ), opts )
  end


  def path( hash, ext )
    self.class.path( self, hash, ext, self.secure?, self.origin_ftp_path_prefix, self.protect_path_prefix )
  end


  # bg_hp: VideoContentHostingProviderOnDemandBitGravity
  # hash: md5 file hash
  # ext: file extension
  def self.path( bg_hp, hash, ext, protected, origin_ftp_path_prefix, secure_prefix )
    components = []

    components.concat( secure_prefix.split('/').reject{|p| p.empty?} ) if protected
    components.concat( origin_ftp_path_prefix.split('/').reject{|p| p.empty?} )
    components.reject!{|c| c.empty?}

    components << hash[0..1]
    components << hash[2..3]
    components << hash[4..-1]
    components[components.length - 1] += '.' + ext
    '/' + components.join('/')
  end



# required for video content for some reason :/
	def instance_local_file_path
		( ( ( Pathname.new(RAILS_ROOT) + 'private' ) + 'videos' ) + self.local_path_name ).to_s
	end

end
