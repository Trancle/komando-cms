require File.dirname(__FILE__) + '/../modules/cw_mu_ex_date_range_nil_form.rb'
class UserInputBanScheduleRange < ActiveRecord::Base
	include CW::MuExDateRange::Range
	belongs_to :user, :foreign_key => :exclusivity_id
	include CW::MuExDateRange::RangeWithNilForm
end
