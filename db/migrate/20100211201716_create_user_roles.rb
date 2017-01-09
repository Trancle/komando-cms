class CreateUserRoles < ActiveRecord::Migration
  def self.up
    create_table :user_roles do |t|
			t.column :name, :string, :limit => 256, :null => false
			t.column :description, :string, :null => true
      t.timestamps
    end
		add_index :user_roles, :name, :unique => true
  end

  def self.down
    drop_table :user_roles
  end
end
