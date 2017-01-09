class CreateLinkShowToRelatedShows < ActiveRecord::Migration
  def self.up
    create_table :link_show_to_related_shows do |t|
			t.column :show_id, :integer, :null => false
			t.column :related_show_id, :integer, :null => false
			t.column :weight, :float, :null => false, :default => 1.0
      t.column :created_at, :timestamp, :null => false
    end
  end

  def self.down
    drop_table :link_show_to_related_shows
  end
end
