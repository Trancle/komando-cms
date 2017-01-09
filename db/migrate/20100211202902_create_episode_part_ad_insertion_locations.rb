class CreateEpisodePartAdInsertionLocations < ActiveRecord::Migration
  def self.up
    create_table :episode_part_ad_insertion_locations do |t|
			t.column :type, :string
			# insertion location ALWAYS associated with an episode
			t.column :episode_part_id, :integer, :null => false
			# used only for mid-rolls, which aren't ready at the time of model creation
			t.column :offset_from_start, :float, :null => true
			t.column :enabled, :boolean, :default => true, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :episode_part_ad_insertion_locations
  end
end
