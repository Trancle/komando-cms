class CreateHomePageLineups < ActiveRecord::Migration
  def self.up
    create_table :home_page_lineups do |t|
			t.column :notes, :text
      t.timestamps
    end
  end

  def self.down
    drop_table :home_page_lineups
  end
end
