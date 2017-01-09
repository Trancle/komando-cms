class AddWatchPageLimitToShow < ActiveRecord::Migration
  def self.up
    add_column :shows, :number_watch_page_episodes, :integer, :null => false, :default => 6
  end

  def self.down
    remove_column :shows, :number_watch_page_episodes
  end
end
