class RecreateHomePageLinups < ActiveRecord::Migration
  def self.up
    drop_table :home_page_lineups
  end

  def self.down
    raise IrreversibleMigration.new
  end
end
