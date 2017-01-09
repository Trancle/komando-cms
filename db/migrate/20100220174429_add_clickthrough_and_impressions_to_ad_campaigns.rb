class AddClickthroughAndImpressionsToAdCampaigns < ActiveRecord::Migration
  def self.up
		add_column :ad_campaigns, :click_through_count, :integer
		add_column :ad_campaigns, :impression_count, :integer
  end

  def self.down
		remove_column :ad_campaigns, :click_through_count
		remove_column :ad_campaigns, :impression_count
  end
end
