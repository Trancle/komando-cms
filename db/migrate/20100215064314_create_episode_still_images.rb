class CreateEpisodeStillImages < ActiveRecord::Migration
	include CW::ManagedFileResource::Migration
  def self.up
    create_managed_file_resource_table :episode_still_images do |t|
			t.column :alt_text, :string, :null => true
    end
  end

  def self.down
    drop_table :episode_still_images
  end
end
