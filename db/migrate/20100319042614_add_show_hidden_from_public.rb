class AddShowHiddenFromPublic < ActiveRecord::Migration
  def self.up
		add_column :shows, :hide_from_listings, :boolean, :null => false, :default => false
  end

  def self.down
		remove_column :shows, :hide_from_listings
  end
end
