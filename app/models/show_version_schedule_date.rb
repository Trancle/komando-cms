require File.dirname(__FILE__) + '/../modules/cw_mu_ex_date_range_nil_form.rb'
class ShowVersionScheduleDate < ActiveRecord::Base
	include CW::MuExDateRange::Range
	def self.scheduled_version_klass; 'ShowVersionSchedule'.constantize; end
	include CW::ScheduledVersion::DateRange
	include CW::MuExDateRange::RangeWithNilForm
end
