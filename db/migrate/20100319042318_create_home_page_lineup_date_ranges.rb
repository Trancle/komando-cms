class CreateHomePageLineupDateRanges < ActiveRecord::Migration
	include CW::MuExDateRange::Migration
  def self.up
    create_date_range_table :home_page_lineup_date_ranges do |t|
			t.column :home_page_lineup_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :home_page_lineup_date_ranges
  end
end
