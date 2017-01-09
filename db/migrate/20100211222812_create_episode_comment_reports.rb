class CreateEpisodeCommentReports < ActiveRecord::Migration
  def self.up
    create_table :episode_comment_reports do |t|
			# so we can track who posted it :-)
			# also tracks the time the event occured. Neat, eh?
			t.column :request_log_id, :integer, :null => true
			t.column :episode_comment_id, :integer, :null => true
			t.column :reason, :string, :null => true
    end
  end

  def self.down
    drop_table :episode_comment_reports
  end
end
