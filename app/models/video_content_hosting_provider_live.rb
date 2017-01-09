class VideoContentHostingProviderLive < VideoContentHostingProvider
	VALID_SUBCLASSES = %w(VideoContentHostingProviderLiveLimelightFlashLiveStream VideoContentHostingProviderLiveBitgravity).freeze
	def self.is_valid_subclass?( v )
		VALID_SUBCLASSES.include?(v)
	end
end
