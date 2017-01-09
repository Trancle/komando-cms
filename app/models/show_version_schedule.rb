class ShowVersionSchedule < ActiveRecord::Base
	def self.scheduled_version_stub_klass; "Show".constantize; end
	def self.versioned_model_klass; "ShowVersion".constantize; end
	def self.scheduled_version_cw_mu_ex_date_range_range_klass; 'ShowVersionScheduleDate'.constantize; end
	include CW::ScheduledVersion::Base
end
