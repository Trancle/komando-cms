class LinkAdCampaignWithAdCampaignTag < ActiveRecord::Base
	def self.taggable_klass; "AdCampaign".constantize; end
	include CW::ActsAs::Taggable::Link
end
