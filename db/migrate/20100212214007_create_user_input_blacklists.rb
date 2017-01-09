class CreateUserInputBlacklists < ActiveRecord::Migration
	include CW::ActsAs::Blacklistable::Migration
  def self.up
    create_blacklist_table :user_input_blacklists
	end

  def self.down
    drop_table :user_input_blacklists
  end
end
