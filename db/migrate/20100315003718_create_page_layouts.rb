class CreatePageLayouts < ActiveRecord::Migration
	include CW::MuExDateRange::Migration
	include CW::ActsAs::Versioned::Migration
	include CW::ScheduledVersion::Migration
  def self.up
    create_table :page_layouts do |t|
			t.column :programmatic_name, :string, :null => false
			t.column :name, :string, :null => false
			t.column :description, :text
      t.timestamps
    end
		add_index :page_layouts, [:programmatic_name], :unique => true
		add_stub_fields( "PageLayout" )
    create_versioned_table "PageLayoutVersion" do |t|
			t.column :layout, :text, :null => false
			t.column :editor_id, :integer
			t.timestamps
		end
    create_scheduled_version_table :page_layout_schedules
    create_date_range_table :page_layout_schedule_date_ranges
  end

  def self.down
		drop_table :page_layout_schedule_date_ranges
    drop_table :page_layout_schedules
		drop_table :page_layout_versions
    drop_table :page_layouts
  end
end
