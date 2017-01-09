class AddShowSplashImageToShowVersion < ActiveRecord::Migration
  def self.up
		add_column :show_versions, :show_splash_image_id, :integer
  end

  def self.down
		remove_column :show_versions, :show_splash_image_id
  end
end
