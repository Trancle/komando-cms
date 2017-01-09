class RemoveHomePageLimeupDateRanges < ActiveRecord::Migration
  def self.up
    drop_table :home_page_lineup_date_ranges
  end

  def self.down
    raise IrreversibleMigration.new
  end
end
