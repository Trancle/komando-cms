class VideoContentHostingProviderOnDemand < VideoContentHostingProvider
	VALID_SUBCLASSES = %w(VideoContentHostingProviderOnDemandLimelightCoreStorageAndHttp VideoContentHostingProviderOnDemandBitgravity).freeze
	def self.is_valid_subclass?( v )
		VALID_SUBCLASSES.include?(v)
	end



### Ready for upload Callback
#
# Informs (usually the video content being created and uploaded) the hosting provider model that the video content is ready for upload. A VideoContent record exists and file is uploaded to the temporary store. Subclasses should arrange to upload the video to the CDN
#
# @param[in] video_content The video content that is ready for upload
# @return return value is ignored
	def video_content_ready_for_upload( video_content )
		raise NotImplementedError.new
		
	end

### Video Content Removed Callback
#
# Informs (usually the video content getting deleted) the hosting provider model that the video content has been removed (destroyed or deleted). A VideoContent record no longer exists and file is no longer at the temporary store. Subclasses should arrange to remove the video from the CDN
#
# @param[in] video_content The video content that is ready for upload
# @return return value is ignored
	def video_content_removed( video_content )
		raise NotImplementedError.new
	end


### Delete file
#
# Deletes one file from the CDN immediately, no callbacks are called. While it would be nice to have the video_content record, by this point, it's usually been deleted from the database.
#
# @param[in] file_info The information required to accurately identify the file to be removed. This is highly dependend on the CDN and, by extension, the subclass implementor. The file details should be a hash of the required information
# @returns True if file is no longer at the CDN, false if it's still there, for whatever reason
	def delete_from_provider( file_info = {} )
		raise NotImplementedError.new
	end

### Upload file
	# "puts" one file to the CDN immediately, no callbacks are called
	# This can be ignored if the CDN does not need the file to be transferred and reads it from the network
	def upload_to_provider( file_info = {} )
		raise NotImplementedError.new
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
		raise NotImplementedError.new
	end

end
