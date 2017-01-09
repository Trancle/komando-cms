class AddFieldsToContentVideos < ActiveRecord::Migration
	include CW::ManagedFileResourceName::Migration
  def self.up
		add_managed_file_resource_name_columns_to_mfr( :video_contents )
		add_column :video_contents, :uploader_user_id, :integer
  end

  def self.down
		remove_column :video_contents, :uploader_user_id
		remove_managed_file_resource_name_columns_from_mfr( :video_contents )
  end
end
