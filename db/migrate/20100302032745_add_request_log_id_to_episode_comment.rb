class AddRequestLogIdToEpisodeComment < ActiveRecord::Migration
  def self.up
		add_column :episode_comments, :request_log_id, :integer
  end

  def self.down
		remove_column :episode_comments, :request_log_id
  end
end
