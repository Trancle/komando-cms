class UserInputBanSchedule
	include CW::MuExDateRange::Set
	def self.cw_mu_ex_date_range_range_klass; 'UserInputBanScheduleRange'.constantize; end
end
