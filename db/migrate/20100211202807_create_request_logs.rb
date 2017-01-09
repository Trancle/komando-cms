class CreateRequestLogs < ActiveRecord::Migration
	include CW::RequestLog::Migration
  def self.up
    create_request_log_table :request_logs do |t|
			t.column :user_id_or_nil, :integer, :null => true
		end
  end

  def self.down
    drop_table :request_logs
  end
end
