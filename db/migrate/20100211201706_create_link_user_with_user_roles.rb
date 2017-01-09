class CreateLinkUserWithUserRoles < ActiveRecord::Migration
  def self.up
    create_table :link_user_with_user_roles do |t|
			t.column :user_id, :integer, :null => false
			t.column :user_role_id, :integer, :null => false
			t.column :enabled, :boolean, :null => false, :default => true
      t.timestamps
    end
		add_index :link_user_with_user_roles, [:user_id, :user_role_id], :unique => true
  end

  def self.down
    drop_table :link_user_with_user_roles
  end
end
