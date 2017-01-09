class VideoContentHostingProvider < ActiveRecord::Base
	include FreeFormModelAttributeModel

	composed_of :configuration, :class_name => "FreeFormModelAttribute", :mapping => %w(sub_configuration to_composition)
	before_validation :commit_sub_configuration

	private
		def commit_sub_configuration
			self.configuration = self.configuration.dup
		end
	public

	has_one :video_content

	validates_presence_of :name
	validates_length_of :name, :in => 2..255
	validates_uniqueness_of :name

	validates_length_of :description, :maximum => 4048, :allow_nil => true, :allow_blank => true


	VALID_SUBCLASSES = %w(VideoContentHostingProviderLive VideoContentHostingProviderOnDemand).freeze
	def self.valid_subclass?( v )
		VALID_SUBCLASSES.include?(v)
	end

	def self.valid_sub_subclass?( v )
		sc = subclass_from_sub_subclass( v )
		if valid_subclass?( sc )
			return sc.constantize.is_valid_subclass?( v )
		else
			return false
		end
	end

	def self.subclass_from_sub_subclass( subsubclass )
		VALID_SUBCLASSES.find(nil) do |sc|
			subsubclass.start_with?( sc )
		end
	end

# subclass (String)
	def self.subclass_name( subclass )
		subsub = sub_subclass_name(subclass)
		t = subclass[self.name.length..-1]
		unless subsub.nil?
			t[0..(-1*(subsub.length + 1))]
		else
			t
		end
	end

	def self.sub_subclass_name( subsubclass )
		sc = subclass_from_sub_subclass( subsubclass )
		return nil if sc.nil?
		subsubclass[sc.length..-1]
	end

	# check if this hosting provider is being used by any content, currently
	def used?
		!VideoContent.find( :first, :conditions => ['video_content_hosting_provider_id = ?',self.id] ).nil?
	end

	# Renders the Hash of SQL parameters that determine who is using this provider
	def used_by_sql( options = { :limit => 10, :offset => 0 } )
		options.merge( { :conditions => ['video_content_hosting_provider_id = ?', self.id] } )
	end


	def content_model_name
		raise NotImplementedError.new
	end

	def deactivated?
		!self.enable
	end


end
