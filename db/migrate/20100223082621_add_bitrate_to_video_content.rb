class AddBitrateToVideoContent < ActiveRecord::Migration
  def self.up
		add_column :video_contents, :bitrate, :integer
  end

  def self.down
		remove_column :video_contents, :bitrate
  end
end
