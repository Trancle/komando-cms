class AddUuidToUsers < ActiveRecord::Migration
  def self.up
    # add uuid to users
    add_column :users, :uuid, :string

    # need a password for users
    add_column :users, :password_hash, :string

    # add level requirement for episodes
    add_column :episodes, :required_levels, :string
  end

  def self.down
    remove_column :users, :uuid
    remove_column :users, :password_hash

    # add level requirement for episodes
    remove_column :episodes, :required_levels
  end
end
