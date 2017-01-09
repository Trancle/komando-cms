class AddEpisodesPerPageToShows < ActiveRecord::Migration
  def self.up
		add_column :shows, :episodes_per_page, :integer, :null => false, :default => 20
  end

  def self.down
		remove_column :shows, :episodes_per_page
  end
end
