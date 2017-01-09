class AddEpisodeLookupIndexes < ActiveRecord::Migration
  def self.up
    add_index :episode_parts, :episode_id
    add_index :video_contents, :pretty_name_id
  end

  def self.down
    remove_index :video_contents, :pretty_name_id
    remove_index :episode_parts, :episode_id
  end
end
