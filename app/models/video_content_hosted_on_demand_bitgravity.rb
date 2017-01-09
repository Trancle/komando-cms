class VideoContentHostedOnDemandBitgravity < VideoContentHostedOnDemand

	def after_destroy
		remove_file_from_hosting_provider
	end

	def remove_file_from_hosting_provider
		self.video_content_hosting_provider.video_content_removed( self )
		true
	end

	def short_name
		truncate self.file_hash
	end

# we need to save and schedule the upload
	def upload_and_save
		if save
			video_content_hosting_provider.video_content_ready_for_upload( self )
			return true
		else
			return false
		end
	end

	def upload_and_save!
		save!
		video_content_hosting_provider.video_content_ready_for_upload( self )
		true
  end


  def http_url
    # Add 10% for play time to link expiration. CLock skew and current time are added to UNIX Epoch
    self.video_content_hosting_provider.http_uri( self.file_hash, self.file_extension, :expires_in => (self.length_in_seconds*1.1).ceil )
  end

### Check to see if this file is uploaded to the CDN
#
# @return true if it's been published to the CDN, false if not
	def exists_at_cdn?
		video_content_hosting_provider.exists?( self )
	end


	def instance_local_file_path
		( ( ( Pathname.new(RAILS_ROOT) + 'private' ) + 'videos' ) + self.local_path_name ).to_s
	end

end
