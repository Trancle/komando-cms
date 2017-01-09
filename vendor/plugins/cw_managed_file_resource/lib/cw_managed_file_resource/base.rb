require 'openssl'
module CW
module ManagedFileResource

	# The base class model for the file resource
	module ModelFile
		def self.included(base)
			base.extend(ClassMethods)
			base.send(:compile_file_ext_to_mime_type_translation)
			base.validates_uniqueness_of :file_hash, :allow_nil => true
		end


		# Get the Pathname of this file as stored on server's disk
		def local_path
			if file_hash
				return self.class.local_file_path( self, file_hash )
			else
				return nil
			end
		end

		# Get the Pathname.to_s of this file
		def local_path_name
			local_path.to_s
		end

		# upload
		def upload( attrs = {} )
			# nothing uploaded?
			self.errors.add( self.class.uploaded_file_attribute_name, 'must have a file selected to upload' ) and return false if attrs[self.class.uploaded_file_attribute_name].nil?

			raise ArgumentError.new( "MangedFileResource::Model: Forms must have an enctype='multipart/form-data' over POST'" ) if attrs[self.class.uploaded_file_attribute_name].is_a?(String)

			original_path = self.local_path
			oldid = self.id
			# delete the file if necessary
			result = self.class.upload( self, attrs[self.class.uploaded_file_attribute_name] )
			# no errors
			if original_path and result.errors.empty?
				# replaced the old file, try to delete it, but not if it's an existing file (tried to upload to an existant file)
				Model.delete_file( original_path ) unless oldid.eql?( result.id )
			end
			return (!result.nil? and result.errors.empty?)
		end


		def store_from_local( file_handle, mime_type = nil )
			if file_handle.is_a?(String)
				mime_type = self.class.guess_mime_type_from_file_extension( File.extname(file_handle) )
				file_handle = File.open( file_handle, File::RDONLY )
			end
			original_path = self.local_path
			oldid = self.id
			# delete the file if necessary
			result = self.class.store( self, file_handle, mime_type )
			# no errors
			if original_path and result.errors.empty?
				# replaced the old file, try to delete it, but not if it's an existing file (tried to upload to an existant file)
				Model.delete_file( original_path ) unless oldid.eql?( result.id )
			end
			return result
			
		end


		def destroy
			before_destroy
			release
			if unreferenced?
				before_remove_file
				# reference count is zero
				self.class.delete_file( self.local_path )
				after_remove_file
			end
			self.class.delete( self.id )
			after_destroy
		end

		def before_remove_file
		end

		def after_remove_file
		end

		def retain
			self.reference_count = self.reference_count + 1
			self
		end

		def release
			self.reference_count = self.reference_count - 1 unless self.reference_count.eql?(0)
			self
		end

		def unreferenced?
			self.reference_count.eql?(0)
		end


		module ClassMethods
			# Override if you change the file attribute name
			def uploaded_file_attribute_name
				:file_path
			end

			def delete_file( path )
				begin
					path.unlink
					return true
				rescue
					return false
				end
			end

			def upload( model, file )
				model.class.store( model, file )
			end

			def store( m, file, mime_type = nil )
				hexhash, size = m.class.hash_file_and_get_length( m, file )
				m.file_hash = hexhash
				m.file_size = size
				mime = mime_type || m.class.determine_mime_type( file )
				if m.only_mime_types
					unless m.only_mime_types.detect{|mt| mt.eql?(mime)}
						m.errors.add(:mime_type, "Cannot store files with a MIME type of \"#{mime}\"")
						return m
					end
				end
				# use default of text... just to be safe
				m.mime_type = mime || 'text/txt'

				# see if we already have the file
				existing = m.class.find(:first, :conditions => "file_hash = '#{hexhash}'" )
				return existing if existing

				# does not exist
				path = m.class.create_local_file_path( m, hexhash )
				# we now have a place to put the file
				m.class.store_file_to( m, file, path )
				unless m.save
					# something happened, unstore the file
					begin
						path.unlink
					rescue
					end
				end
				return m
			end

			def hash_file_and_get_length( model, file )
				chunksize = model.class.file_chunk_size
				dgst = OpenSSL::Digest::SHA512.new
				buf = ''
				sz = 0
				file.rewind
				while( !file.eof? )
					buf = file.read( chunksize )
					sz += buf.length
					dgst.update( buf )
				end
				return dgst.hexdigest, sz
			end

			def create_local_file_path( model, hexhash )
				path = Pathname.new(model.class.base_path)
				raise IOError.new( "No such file or directory: \"#{model.class.base_path}\", please make sure it exists" ) unless path.exist?

				local_file_path_from_hash( path, hexhash ) do |p|
					p.mkdir unless p.exist?
				end
			end

			def local_file_path( model, hexhash )
				local_file_path_from_hash( Pathname.new( model.class.base_path ), hexhash )
			end

			def local_file_path_from_hash( path, hexhash, &block )
				file_hsh = hexhash.dup
				until( file_hsh.length < local_directory_max_name_length )
					path = path.join( file_hsh.slice!(0..local_directory_max_name_length-1) )
					yield(path) if block_given?
				end
				# there are now 2 letters left, this is the filename
				path = path.join(file_hsh)
			end

			def local_directory_max_name_length
				3
			end

			def store_file_to( model, file, file_path )
				filechunk = model.class.file_chunk_size
				file.rewind
				file_path.open( 'wb+' ) do |f|
					until file.eof?
						f.write( file.read( file_chunk_size ) )
					end
				end
			end


			def base_path
				RAILS_ROOT + '/public/resources/files'
			end

			def external_mime_type_checker( file )
				nil
			end

			def file_chunk_size
				10.kilobytes
			end

			def determine_mime_type( file )
				t = external_mime_type_checker( file )
				if t.nil?
					t = file.content_type.chomp if file.respond_to?(:content_type) and file.content_type
				end
				return t
			end

			def file_extension( mime_type )
				MIME_TYPE_TO_EXT[mime_type]
			end

			def compile_file_ext_to_mime_type_translation
				t = MIME_TYPE_TO_EXT.keys.inject(Hash.new) {|m,o| m[MIME_TYPE_TO_EXT[o]] = o; m }
				# file extension aliases here
				t['jpeg'] = 'image/jpg'
				t['c'] = 'text/plain'
				t['h'] = 'text/plain'
				t['cpp'] = 'text/plain'
				t['java'] = 'text/plain'
				t['rb'] = 'text/plain'
				t['c++'] = 'text/plain'
				t['cxx'] = 'text/plain'
				# prevent modification at run time
				t.freeze
				const_set("EXT_TO_MIME_TYPE", t )
			end
			def guess_mime_type_from_file_extension( ext )
				ext = ext.slice(1,ext.length - 1) if ext[0] == ?.
				# guess it or use the default
				EXT_TO_MIME_TYPE[ext]
			end
		end#ClassMethods

		def file_extension
			self.class.file_extension( self.mime_type )
		end


		def only_mime_types
			nil
		end



		MIME_TYPE_TO_EXT = { 
			"image/gif" => "gif",
			"image/jpeg" => "jpg",
			"image/x-png" => "png",
			"image/jpg" => "jpg",
			"image/png" => "png",
			"image/tiff" => "tiff",
			"image/svg+xml" => "svg",
			"image/vnd.microsoft.icon" => "ico",
			"application/x-shockwave-flash" => "swf",
			"application/pdf" => "pdf",
			"application/pgp-signature" => "sig",
			"application/futuresplash" => "spl",
			"application/vnd.oasis.opendocument.text" => 'odt',
			"application/vnd.oasis.opendocument.spreadsheet" => 'ods',
			"application/vnd.oasis.opendocument.presentation" => 'odp',
			"application/vnd.oasis.opendocument.graphics" => 'odg',
			"application/msword" => "doc",
			"application/vnd.ms-excel" => "xls",
			"application/vnd.ms-powerpoint" => "ppt",
			"application/postscript" => "ps",
			"application/x-bittorrent" => "torrent",
			"application/x-dvi" => "dvi",
			"application/xhtml+xml" => "xhtml",
			'application/ogg' => 'ogg',
			"application/json" => 'json',
			'application/xml-dtd' => 'dtd',
			"application/x-gzip" => "gz",
			"application/x-ns-proxy-autoconfig" => "pac",
			"application/x-shockwave-flash" => "swf",
			"application/x-tgz" => "tar.gz",
			"application/x-tar" => "tar",
			"application/zip" => "zip",
			"audio/mpeg" => "mp3",
			"audio/mp4" => "mp4",
			"audio/ogg" => "ogg",
			"audio/x-mpegurl" => "m3u",
			"audio/x-ms-wma" => "wma",
			"audio/x-ms-wax" => "wax",
			"audio/x-wav" => "wav",
			"image/x-xbitmap" => "xbm",
			"image/x-xpixmap" => "xpm",
			"image/x-xwindowdump" => "xwd",
			"text/css" => "css",
			"text/csv" => "csv",
			"text/html" => "html",
			"text/javascript" => "js",
			"text/plain" => "txt",
			"text/xml" => "xml",
			"video/mpeg" => "mpeg",
			"video/mp4" => "mp4",
			"video/quicktime" => "mov",
			"video/ogg" => 'ogg',
			"video/x-msvideo" => "avi",
			"video/x-ms-asf" => "asf",
			"video/x-ms-wmv" => "wmv",
			"video/x-flv" => "flv"
		 }.freeze


	end#Model


	module ModelPublicFile
		def self.included( base )
			# nothing to do!
			base.send(:include,ModelFile)
		end
	end#ModelPublicFile

	module ModelPublicImage
		def self.included(base)
			# nothing to do!
			base.send(:include,ModelFile)
			base.extend(ClassMethods)
		end
		module ClassMethods
			def only_mime_types
				['image/gif','image/jpeg','image/png','image/tiff']
			end
			def base_path
				RAILS_ROOT + '/public/resources/images'
			end
		end#ClassMethods
	end#ModelPublicImage

	module ModelPrivateFile
		def self.included(base)
			# nothing to do!
			base.send(:include,ModelFile)
			base.extend(ClassMethods)
		end
		module ClassMethods
			def base_path
				RAILS_ROOT + '/private/managed_file_resources/'
			end
		end#ClassMethods
	end#ModelPrivateFile


end#ManagedFileResource
end#CW
