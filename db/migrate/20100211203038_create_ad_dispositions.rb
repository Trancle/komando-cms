class CreateAdDispositions < ActiveRecord::Migration
  def self.up
    create_table :ad_dispositions do |t|
			t.column :type, :string
			# Weighting, only used in SOME cases
			t.column :weight, :float, :null => true, :default => 1.0
			t.column :ad_type, :string
			t.column :ad_id, :integer
			t.column :insertion_type, :string
			t.column :insertion_id, :integer
			t.column :enabled, :boolean, :null => false, :default => true
      t.timestamps
    end
		add_index :ad_dispositions, [:ad_type,:ad_id,:insertion_type,:insertion_id], :unique => true
  end

  def self.down
    drop_table :ad_dispositions
  end
end
