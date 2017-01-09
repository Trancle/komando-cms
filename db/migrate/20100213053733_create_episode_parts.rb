class CreateEpisodeParts < ActiveRecord::Migration
	include CW::ActsAs::Ordered::Migration
  def self.up
    create_table :episode_parts do |t|
			t.column :video_content_name_id, :integer, :null => true
			t.column :episode_id, :integer, :null => false
			t.column :name, :string, :null => true
			t.column :play_count, :integer, :null => false, :default => 0
      t.timestamps
    end
		add_order( 'EpisodePart', :acts_as_ordered_order )
  end

  def self.down
    drop_table :episode_parts
  end
end
