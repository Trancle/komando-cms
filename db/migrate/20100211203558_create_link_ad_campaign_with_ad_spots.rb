class CreateLinkAdCampaignWithAdSpots < ActiveRecord::Migration
  def self.up
    create_table :link_ad_campaign_with_ad_spots do |t|
			t.column :ad_spot_id, :integer, :null => false
			t.column :ad_campaign_id, :integer, :null => false
    end
		add_index :link_ad_campaign_with_ad_spots, [:ad_spot_id,:ad_campaign_id], :unique => true
  end

  def self.down
    drop_table :link_ad_campaign_with_ad_spots
  end
end
