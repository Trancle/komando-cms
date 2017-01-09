module CW
module ScheduledVersion

	module Version
		def self.included(base)
			base.extend(ClassMethods)
			raise NotImplementedError.new( "You must create the function: scheduled_version_klass class method in #{base.name} and have it return the class that includes CW::ScheduledVersion::Base" ) unless base.respond_to?:scheduled_version_klass
			base.has_many :scheduled_versions, :class_name => base.scheduled_version_klass.name, :foreign_key => 'version_id', :dependent => :destroy
		end

		# Links up a version with a range. Assume the range is completely new


		module ClassMethods
		end # ClassMethods
	end # Version

end #ScheduledVersion
end # CW
