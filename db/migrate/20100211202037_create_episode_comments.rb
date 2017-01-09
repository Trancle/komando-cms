class CreateEpisodeComments < ActiveRecord::Migration
  def self.up
    create_table :episode_comments do |t|
			t.column :type, :string, :null => false
			t.column :user_id, :integer, :null => false
			t.column :episode_id, :integer, :null => false
			t.column :parent_comment_id, :integer, :null => true
			t.column :title, :string, :null => false
			t.column :body, :text, :null => false
			t.column :visible, :boolean, :null => false, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :episode_comments
  end
end
