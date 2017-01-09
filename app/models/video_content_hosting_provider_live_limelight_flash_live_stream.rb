class VideoContentHostingProviderLiveLimelightFlashLiveStream < VideoContentHostingProviderLive
	ffma_create_attribute 'configuration', 'stream_protocol', :string
	ffma_create_attribute 'configuration', 'stream_host', :string
	ffma_create_attribute 'configuration', 'stream_application_name', :string

	ffma_create_attribute 'configuration', 'media_vault_enable', :bool, true
	ffma_create_attribute 'configuration', 'media_vault_secret', :string
	ffma_create_attribute 'configuration', 'media_vault_uri_base', :string

	ffma_create_attribute 'configuration', 'media_vault_security_enforce_referrer', :bool, false
	ffma_create_attribute 'configuration', 'media_vault_security_enforce_ip', :bool, false

	ffma_create_attribute 'configuration', 'media_vault_security_enforce_time', :bool, true
	ffma_create_attribute 'configuration', 'media_vault_security_time_interval_in_seconds', :integer, 3600

	VALID_STREAM_PROTOCOLS = %w(rtmpt rtmp rtmpe rtmps).freeze
	validates_presence_of 'stream_protocol'
	validates_length_of 'stream_protocol', :in => 3..255
	validates_inclusion_of 'stream_protocol', :in => VALID_STREAM_PROTOCOLS

	validates_presence_of 'stream_host'
	validates_length_of 'stream_host', :in => 4..255
	validates_format_of 'stream_host', :with => /\A[a-z0-9\-\.]+\Z/i

	validates_presence_of 'stream_application_name'
	validates_length_of 'stream_application_name', :in => 1..255
	validates_format_of 'stream_application_name', :with => /\A[a-z0-9\-_\/\.]+[a-z0-9_\-\.]\Z/i


	validates_presence_of 'media_vault_secret', :if => :use_media_vault?
	validates_length_of 'media_vault_secret', :in => 10..64, :if => :use_media_vault?

	validates_presence_of 'media_vault_security_time_interval_in_seconds', :if => :media_vault_security_enforce_time
	validates_numericality_of 'media_vault_security_time_interval_in_seconds', :only_integer => true, :greater_than => 0, :if => :media_vault_security_enforce_time





	def use_media_vault?
		self.media_vault_enable
	end

	def stream_uri( stream_name = '' )
		h = Pathname.new(self.stream_host)
		hp = h + self.stream_application_name + stream_name
		self.stream_protocol + '://' + hp.to_s
	end

	def content_model_name
		'VideoContentHostedLiveLimelightFlashLiveStream'
	end



	def valid_stream_protocol_options
		VALID_STREAM_PROTOCOLS.collect{|p| [p.downcase,p] }
	end

end
