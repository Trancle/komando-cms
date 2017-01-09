class AddUidToUser < ActiveRecord::Migration
  def self.up
		add_column :users, :email, :string, :null => true
		add_column :users, :uid, :integer, :null => true
		add_column :users, :last_login_timestamp, :timestamp, :null => true
  end

  def self.down
		remove_column :users, :last_login_timestamp
		remove_column :users, :uid
		remove_column :users, :email
  end
end
