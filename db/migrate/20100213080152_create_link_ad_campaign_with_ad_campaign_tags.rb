class CreateLinkAdCampaignWithAdCampaignTags < ActiveRecord::Migration
	include CW::ActsAs::Taggable::LinkMigration
  def self.up
    create_link_tags_with_taggable_table :link_ad_campaign_with_ad_campaign_tags
  end

  def self.down
    drop_table :link_ad_campaign_with_ad_campaign_tags
  end
end
