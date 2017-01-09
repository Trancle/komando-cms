class IncreaseReferrerSizeInRequestLog < ActiveRecord::Migration
  def self.up
		change_column :request_logs, :accept_language, :string, :limit => 64, :null => true
  end

  def self.down
  end
end
