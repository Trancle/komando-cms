class AddTypeToShows < ActiveRecord::Migration
  def self.up
    add_column :shows, :type, :string
  end

  def self.down
    remove_column :shows, :type
  end
end
