class EpisodePublishScheduleDateSet
	include CW::MuExDateRange::Set
	def self.cw_mu_ex_date_range_range_klass; "EpisodePublishScheduleDate".constantize; end
end
