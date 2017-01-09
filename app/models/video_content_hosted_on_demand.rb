class VideoContentHostedOnDemand < VideoContent
	VALID_TYPES = %w(LimelightCoreStorageAndHttp Bitgravity).freeze
	include FreeFormModelAttributeModel

	composed_of :hosting_attrs, :class_name => "FreeFormModelAttribute", :mapping => %w(type_information to_composition)
	before_validation :commit_hosting_attrs

	def commit_hosting_attrs
		self.hosting_attrs = self.hosting_attrs.dup
	end
	private :commit_hosting_attrs

	validates_presence_of :uploader_user_id
	validates_presence_of :type
	validates_inclusion_of :type, :in => VideoContentHostedOnDemand::VALID_TYPES.collect{|x| 'VideoContentHostedOnDemand' + x }
# video_content_name_id is deprecated and is never set or read: use pretty_name_id ALWAYS
	validates_presence_of :pretty_name_id
	validates_presence_of :video_content_hosting_provider_id

	validates_uniqueness_of :file_hash, :message => 'file already exists on this system'

	validates_presence_of :bitrate, :unless => :new_with_upload_only?
	validates_numericality_of :bitrate, :only_integer => true, :unless => :new_with_upload_only?


	validates_presence_of 'width'
	validates_numericality_of 'width', :only_integer => true, :greater_than => 0

	validates_presence_of 'height'
	validates_numericality_of 'height', :only_integer => true, :greater_than => 0



	ffma_create_attribute 'hosting_attrs', 'audio_codec', :string
	ffma_create_attribute 'hosting_attrs', 'video_codec', :string
	ffma_create_attribute 'hosting_attrs', 'frames_per_second', :float

	validates_presence_of 'audio_codec', :unless => :new_with_upload_only?
	validates_presence_of 'video_codec', :unless => :new_with_upload_only?
	validates_presence_of 'frames_per_second', :unless => :new_with_upload_only?

	validates_length_of 'audio_codec', :minimum => 4, :unless => :new_with_upload_only?
	validates_length_of 'video_codec', :minimum => 4, :unless => :new_with_upload_only?
	validates_numericality_of 'frames_per_second', :greater_than => 0, :unless => :new_with_upload_only?

# A provider must always exist for this class
	validates_each 'video_content_hosting_provider_id' do |record, attr, value|
		record.validates_hosting_provider_id( record, attr, value )
	end


	


	def self.supported_embed_services
		VALID_TYPES
	end
	def self.is_valid_subclass?( v )
		VALID_TYPES.collect{|e| self.name + e }.include?( v )
	end


	def only_mime_types
		%w(video/mp4)
	end


	def self.friendly_type_description
<<ENDOFDOC
<p>Video content we produce that is stored on our systems. It is not live. These are typically pre-recorded and uploaded for Video On Demand use.</p>
ENDOFDOC
	end


	def file_size_in_words
		if self.file_size > 1000000000
			pluralize( self.file_size.to_f/1000000000.0, 'gigabyte' ) + ' (GB)'
		elsif self.file_size > 1000000
			pluralize( self.file_size.to_f/1000000.0, 'megabyte' ) + ' (MB)'
		elsif self.file_size > 1000
			pluralize( self.file_size.to_f/1000.0, 'kilobyte' ) + ' (KB)'
		else
			pluralize( self.file_size, 'byte' ) + ' (B)'
		end
	end


	def new_with_upload_only?
		@upload_only and is_new?
	end

	def set_new_with_upload_only( v = true )
		@upload_only = v
		# don't check length: will be bad
		set_should_validate_colonized_length( false )
	end


	def upload_and_save
		# default is to just save
		save
	end

	def upload_and_save!
		# default is to just save!
		save!
	end




	def can_publish?
		video_content_hosting_provider.exists?( self )
	end


end
