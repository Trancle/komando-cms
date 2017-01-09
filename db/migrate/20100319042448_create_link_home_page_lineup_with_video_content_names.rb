class CreateLinkHomePageLineupWithVideoContentNames < ActiveRecord::Migration
	include CW::ActsAs::Ordered::Migration
  def self.up
    create_table :link_home_page_lineup_with_video_content_names do |t|
			t.column :home_page_lineup_id, :integer, :null => false
			t.column :video_content_name_id, :integer, :null => false
    end
		add_order 'LinkHomePageLineupWithVideoContentName', :acts_as_ordered_order
		add_index :link_home_page_lineup_with_video_content_names, [:home_page_lineup_id,:video_content_name_id], :unique => true
  end

  def self.down
    drop_table :link_home_page_lineup_with_video_content_names
  end
end
