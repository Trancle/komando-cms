class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
			t.column :type, :string
			t.column :username, :string, :null => false, :limit => 256
			t.column :enabled, :boolean, :null => false, :default => true
      t.timestamps
    end
		add_index :users, :username, :unique => true
  end

  def self.down
    drop_table :users
  end
end
