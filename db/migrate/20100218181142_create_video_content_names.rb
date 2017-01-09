class CreateVideoContentNames < ActiveRecord::Migration
	include CW::ManagedFileResourceName::Migration
  def self.up
		create_mfrn_table :video_content_names do |t|
			t.column :uploader_user_id, :integer
			t.timestamps
		end
  end

  def self.down
		drop_mfrn_table :video_content_names
  end
end
