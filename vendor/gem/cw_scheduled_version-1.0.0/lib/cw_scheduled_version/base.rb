# CwScheduledVersion
module CW
module ScheduledVersion

	module Base
		def self.included(base)
			base.extend(ClassMethods)
			base.belongs_to :cw_mu_ex_date_range, :class_name => base.scheduled_version_cw_mu_ex_date_range_range_klass.name, :dependent => :destroy, :foreign_key => 'cw_mu_ex_date_range_id'
			base.belongs_to :version, :class_name => base.versioned_model_klass.name, :foreign_key => 'version_id', :readonly => true
		end

		module ClassMethods

#def scheduled_version_stub_klass
#				raise NotImplementedError.new( "You must override scheduled_version_stub_klass class method and specify the Class string name that represents the scheduled version table (the one that includes CW::ScheduledVersion::Stub)" )
#			end


		end # ClassMethods
	end # Base

end #ScheduledVersion
end #CW
