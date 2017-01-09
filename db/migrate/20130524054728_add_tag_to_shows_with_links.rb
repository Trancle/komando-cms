class AddTagToShowsWithLinks < ActiveRecord::Migration
  def self.up
    create_table :show_tags do |t|
      t.column :tag, :string, :length => 64, :null => false
    end
    add_index :show_tags, :tag, :unique => true

    create_table :show_taggings do |t|
      t.column :show_id, :integer, :null => false
      t.column :tag_id, :integer, :null => false
    end
    add_index :show_taggings, [:show_id,:tag_id], :unique => true

    create_table :episode_taggings do |t|
      t.column :episode_id, :integer, :null => false
      t.column :tag_id, :integer, :null => false
    end
    add_index :episode_taggings, [:episode_id,:tag_id], :unique => true
  end

  def self.down
    drop_table :episode_taggings
    drop_table :show_taggings
    drop_table :show_tags
  end
end
