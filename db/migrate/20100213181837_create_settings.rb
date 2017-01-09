class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
			t.column :name, :string, :null => false
			t.column :programmatic_name, :string, :null => false
			t.column :description, :text, :null => false
			t.column :type, :text
			t.column :value, :text
			t.column :previous_value, :string
      t.timestamps
    end
		add_index :settings, :name, :unique => true
		add_index :settings, :programmatic_name, :unique => true
  end

  def self.down
    drop_table :settings
  end
end
