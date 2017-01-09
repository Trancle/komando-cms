class CreateShowVersions < ActiveRecord::Migration
	include CW::ActsAs::Versioned::Migration
	include CW::ScheduledVersion::Migration
  def self.up
    create_versioned_table "ShowVersion" do |t|
			t.column :description, :text, :null => true
			t.column :title, :string, :limit => 1024, :null => false
			t.column :page_injected_css, :text, :null => true
			t.column :page_injected_javascript, :text, :null => true
			t.column :page_injected_html, :text, :null => true
			t.column :availability_notes, :text, :null => true
			# null means no image
			t.column :show_still_image_id, :integer, :null => true
			t.column :editor_id, :integer, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :show_versions
  end
end
