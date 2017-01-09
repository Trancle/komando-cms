class CreateAdSpotImpressions < ActiveRecord::Migration
  def self.up
    create_table :ad_spot_impressions do |t|
			t.column :ad_spot_id, :integer, :null => false
			t.column :request_log_id, :integer, :null => false
			t.column :ad_campaign_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :ad_spot_impressions
  end
end
