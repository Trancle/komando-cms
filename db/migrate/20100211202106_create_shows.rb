class CreateShows < ActiveRecord::Migration
	include CW::ScheduledVersion::Migration
	include CW::ActsAs::Ordered::Migration
  def self.up
    create_table :shows do |t|
			t.column :published, :boolean, :null => false, :default => false
			t.column :keywords, :string
      t.timestamps
    end
		add_stub_fields( "Show" )
		add_order_with_exclusivity( 'Show', :acts_as_ordered_order, :acts_as_ordered_exclusivity_id )
  end

  def self.down
    drop_table :shows
  end
end
