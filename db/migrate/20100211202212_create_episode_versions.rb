class CreateEpisodeVersions < ActiveRecord::Migration
	include CW::ActsAs::Versioned::Migration
  def self.up
    create_versioned_table "EpisodeVersion" do |t|
			t.column :title, :string, :null => false
			t.column :description, :text, :null => false
			t.column :episode_number, :integer, :null => true
			t.column :season_number, :integer, :null => true
			# null means no image
			t.column :episode_still_image_id, :integer, :null => true
			t.column :editor_id, :integer, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :episode_versions
  end
end
