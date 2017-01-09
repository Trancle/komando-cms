class CreateAdCampaignOwners < ActiveRecord::Migration
  def self.up
    create_table :ad_campaign_owners do |t|
			t.column :company_name, :string, :null => false
			t.column :notes, :text, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :ad_campaign_owners
  end
end
