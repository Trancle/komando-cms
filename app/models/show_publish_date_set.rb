class ShowPublishDateSet < ActiveRecord::Base
	include CW::MuExDateRange::Set
	def self.cw_mu_ex_date_range_range_klass; "ShowPublishDate".constantize; end
end
