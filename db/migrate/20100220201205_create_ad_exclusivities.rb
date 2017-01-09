class CreateAdExclusivities < ActiveRecord::Migration
  def self.up
		create_table :ad_exclusivities do |t|
			t.column :type, :string, :null => false
			t.column :ad_type, :string, :null => false
			t.column :ad_id, :integer, :null => false
			t.column :insertion_id, :integer, :null => false
			t.column :enabled, :boolean, :default => true, :null => false
			t.timestamps
		end
		# order by ad_type: faster searching: also prevent duplicates
		add_index :ad_exclusivities, [:ad_type,:ad_id,:type,:insertion_id], :unique => true
  end

  def self.down
		drop_table :ad_exclusivities
  end
end
