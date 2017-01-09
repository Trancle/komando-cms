class CreateShowPublishDates < ActiveRecord::Migration
	include CW::MuExDateRange::Migration
  def self.up
    create_date_range_table( :show_publish_dates )
  end

  def self.down
    drop_table :show_publish_dates
  end
end
