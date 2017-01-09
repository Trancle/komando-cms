class AddHostingProviderToMfr < ActiveRecord::Migration
  def self.up
		add_column :video_contents, :video_content_hosting_provider_id, :integer, :null => true
  end

  def self.down
		remove_column :video_contents, :video_content_hosting_provider_id
  end
end
