class CreateVideoContents < ActiveRecord::Migration
	include CW::ManagedFileResource::Migration
  def self.up
    create_managed_file_resource_table :video_contents do |t|
			# this is the actual video content... what do we want to store about it?
			t.column :video_content_name_id, :integer
			t.column :type, :string, :null => false
			t.column :length_in_seconds, :float, :null => true, :default => 0.0 # null length indicates indeterminate, a stream
			# Place to store type specific information, such as embedded URL, or a managed file resource ID
			t.column :type_information, :text, :null => true
    end
  end

  def self.down
    drop_table :video_contents
  end
end
