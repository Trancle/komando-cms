class CombineStillsIntoPublicImages < ActiveRecord::Migration
	include CW::ManagedFileResource::Migration
  def self.up
		drop_table :episode_still_images
		drop_table :show_still_images

    create_managed_file_resource_table :public_images do |t|
			t.column :alt_text, :string
			t.column :type, :string
    end

  end

  def self.down
		drop_table :public_images
    create_managed_file_resource_table :episode_still_images do |t|
			t.column :alt_text, :string, :null => true
    end
		create_managed_file_resource_table :show_still_images do |t|
			t.column :alt_text, :string, :null => true
	  end

  end
end
