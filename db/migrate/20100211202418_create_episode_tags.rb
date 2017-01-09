class CreateEpisodeTags < ActiveRecord::Migration
	include CW::ActsAs::Taggable::BaseMigration
  def self.up
    create_tag_table :episode_tags
  end

  def self.down
    drop_table :episode_tags
  end
end
