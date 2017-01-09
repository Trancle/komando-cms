class VideoContentHostedLiveLimelightFlashLiveStream < VideoContentHostedLive
	ffma_create_attribute 'hosting_attrs', 'stream_name', :string

	validates_presence_of 'stream_name'
	validates_format_of 'stream_name', :with => /[a-z0-9_\-]/i

	def short_name
		self.stream_name
	end

	def stream_uri
		self.video_content_hosting_provider.stream_uri( self.stream_name )
	end

end
