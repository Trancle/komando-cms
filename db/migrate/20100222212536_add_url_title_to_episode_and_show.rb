class AddUrlTitleToEpisodeAndShow < ActiveRecord::Migration
  def self.up
		add_column :show_versions, :url_title, :string
		add_column :episode_versions, :url_title, :string
  end

  def self.down
		remove_column :show_versions, :url_title
		remove_column :episode_versions, :url_title
  end
end
