class CreateAdCampaignRunDates < ActiveRecord::Migration
	include CW::MuExDateRange::Migration
  def self.up
    create_date_range_table :ad_campaign_run_dates
  end

  def self.down
    drop_table :ad_campaign_run_dates
  end
end
