class CreateAdSpots < ActiveRecord::Migration
  def self.up
    create_table :ad_spots do |t|
			t.column :type, :string
			t.column :click_to_url, :string, :null => false, :limit => 2048
			t.column :published, :boolean, :null => false, :default => true
			t.column :impression_count, :integer, :null => false, :default => 0
			t.column :click_through_count, :integer, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :ad_spots
  end
end
