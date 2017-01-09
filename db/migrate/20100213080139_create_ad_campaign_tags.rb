class CreateAdCampaignTags < ActiveRecord::Migration
	include CW::ActsAs::Taggable::BaseMigration
  def self.up
    create_tag_table :ad_campaign_tags
  end

  def self.down
    drop_table :ad_campaign_tags
  end
end
