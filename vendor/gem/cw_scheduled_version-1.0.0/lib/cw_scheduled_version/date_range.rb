module CW
module ScheduledVersion

	module DateRange
		def self.included(base)
			base.extend(ClassMethods)
			raise NotImplementedError.new( "You must create the function: scheduled_version_klass class method in #{base.name} and have it return the class that includes  CW::ScheduledVersion::Base" ) unless base.respond_to?:scheduled_version_klass
			base.has_one :scheduled_version, :class_name => base.scheduled_version_klass.name, :dependent => :destroy, :foreign_key => :cw_mu_ex_date_range_id
		end

		module ClassMethods
		end # ClassMethods
	end # DateRange

end #ScheduledVersion
end # CW
