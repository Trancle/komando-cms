class AddHomePageBlocks < ActiveRecord::Migration
  include CW::ActsAs::Ordered::Migration
  def self.up
    create_table :home_page_blocks do |t|
      t.column :type, :string, :null => false
      t.column :type_data, :text, :null => true
      t.column :visible, :bool, :null => false, :default => true
      t.column :machine_name, :string, :null => false
      t.column :block_style, :string, :null => false
      t.column :episode_limit, :integer, :null => false, :default => 6
    end
    HomePageBlock.reset_column_information
    add_order( 'HomePageBlock' )
    add_index :home_page_blocks, [:machine_name], :unique => true
  end

  def self.down
    drop_table :home_page_blocks
  end
end
