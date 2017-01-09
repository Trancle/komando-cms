class CreateLinkEpisodeWithEpisodeTags < ActiveRecord::Migration
	include CW::ActsAs::Taggable::LinkMigration
  def self.up
    create_link_tags_with_taggable_table :link_episode_with_episode_tags
  end

  def self.down
    drop_table :link_episode_with_episode_tags
  end
end
