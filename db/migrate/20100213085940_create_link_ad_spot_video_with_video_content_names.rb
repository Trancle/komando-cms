class CreateLinkAdSpotVideoWithVideoContentNames < ActiveRecord::Migration
  def self.up
    create_table :link_ad_spot_video_with_video_content_names do |t|
			t.column :ad_spot_video_id, :integer, :null => false
			t.column :video_content_name_id, :integer, :null => false
    end
		add_index :link_ad_spot_video_with_video_content_names, [:ad_spot_video_id, :video_content_name_id], :unique => true
  end

  def self.down
    drop_table :link_ad_spot_video_with_video_content_names
  end
end
