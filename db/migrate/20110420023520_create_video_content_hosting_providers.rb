class CreateVideoContentHostingProviders < ActiveRecord::Migration
  def self.up
    create_table :video_content_hosting_providers do |t|
			t.column :type, :string
			t.column :name, :string, :null => false, :limit => 256
			t.column :description, :text
			t.column :sub_configuration, :text
			t.column :enable, :boolean, :null => false, :default => true
			t.column :deprecated, :boolean, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :video_content_hosting_providers
  end
end
