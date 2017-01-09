class AddCommentAndTaggingDisablesToShowAndEpisodes < ActiveRecord::Migration
  def self.up
		add_column :shows, :episode_comments_enabled, :boolean, :default => true, :null => false
		add_column :episodes, :comments_enabled, :boolean, :default => true, :null => false
		add_column :shows, :episode_user_tagging_enabled, :boolean, :default => true, :null => false
		add_column :episodes, :user_tagging_enabled, :boolean, :default => true, :null => false
  end

  def self.down
		remove_column :episodes, :user_tagging_enabled
		remove_column :shows, :episode_user_tagging_enabled
		remove_column :episodes, :comments_enabled
		remove_column :shows, :episode_comments_enabled
  end
end
