class AddDismissedFieldsToEpisodeCommentReport < ActiveRecord::Migration
  def self.up
		add_column :episode_comment_reports, :review_assigned_to_user_id, :integer
		add_column :episode_comment_reports, :reviewed, :boolean, :default => false, :null => false
  end

  def self.down
		remove_column :episode_comment_reports, :review_assigned_to_user_id
		remove_column :episode_comment_reports, :reviewed
  end
end
