class CreateAdCampaigns < ActiveRecord::Migration
  def self.up
    create_table :ad_campaigns do |t|
			t.column :title, :string, :null => true, :limit => 256
			t.column :description, :text, :null => true
			t.column :published, :boolean, :null => false, :default => true
			t.column :ad_campaign_owner_id, :integer, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :ad_campaigns
  end
end
