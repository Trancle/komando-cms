class CreateShowStillImages < ActiveRecord::Migration
	include CW::ManagedFileResource::Migration
  def self.up
    create_managed_file_resource_table :show_still_images do |t|
			t.column :alt_text, :string, :null => true
    end
  end

  def self.down
    drop_table :show_still_images
  end
end
