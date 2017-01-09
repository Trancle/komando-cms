class AddCommentToUserInputBlacklist < ActiveRecord::Migration
  def self.up
		add_column :user_input_blacklists, :comment, :text
  end

  def self.down
		remove_column :user_input_blacklists, :comment
  end
end
