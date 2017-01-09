class VideoContentHostedLive < VideoContent
	include FreeFormModelAttributeModel

	composed_of :hosting_attrs, :class_name => "FreeFormModelAttribute", :mapping => %w(type_information to_composition)
	before_validation :commit_hosting_attrs

	def commit_hosting_attrs
		self.hosting_attrs = self.hosting_attrs.dup
	end
	private :commit_hosting_attrs

	belongs_to :hosting_provider, :class_name => 'VideoContentHostingProvider', :foreign_key => :video_content_hosting_provider_id, :polymorphic => true

	validates_presence_of 'width'
	validates_numericality_of 'width', :only_integer => true, :greater_than => 0

	validates_presence_of 'height'
	validates_numericality_of 'height', :only_integer => true, :greater_than => 0

	validates_presence_of :video_content_hosting_provider_id



	VALID_TYPES = %w(LimelightFlashLiveStream Bitgravity).freeze
	def self.supported_embed_services
		VALID_TYPES
	end
	def self.is_valid_subclass?( v )
		VALID_TYPES.collect{|e| self.name + e }.include?( v )
	end


	validates_presence_of :bitrate
	validates_numericality_of :bitrate, :only_integer => true


# A provider must always exist for this class
	validates_each 'video_content_hosting_provider_id' do |record, attr, value|
		record.validates_hosting_provider_id( record, attr, value )
	end



end
