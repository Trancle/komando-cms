class PageLayoutSchedule < ActiveRecord::Base
	def self.scheduled_version_stub_klass; "PageLayout".constantize; end
	def self.versioned_model_klass; "PageLayoutVersion".constantize; end
	def self.scheduled_version_cw_mu_ex_date_range_range_klass; 'PageLayoutScheduleDateRange'.constantize; end
	include CW::ScheduledVersion::Base
end
