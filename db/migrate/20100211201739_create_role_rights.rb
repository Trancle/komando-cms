class CreateRoleRights < ActiveRecord::Migration
  def self.up
    create_table :role_rights do |t|
			t.column :type, :string, :null => false
			t.column :user_role_id, :integer, :null => false
			t.column :controller_name, :string, :null => false
			t.column :action_name, :string, :null => false
			t.columm :descrption, :string, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :role_rights
  end
end
