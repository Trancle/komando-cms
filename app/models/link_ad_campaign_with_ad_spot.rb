class LinkAdCampaignWithAdSpot < ActiveRecord::Base
	belongs_to :ad_campaign
	belongs_to :ad_spot
end
