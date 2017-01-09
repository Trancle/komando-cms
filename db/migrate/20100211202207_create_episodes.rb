class CreateEpisodes < ActiveRecord::Migration
	include CW::ScheduledVersion::Migration
	include CW::ActsAs::Ordered::Migration
  def self.up
    create_table :episodes do |t|
			t.column :published, :boolean, :null => false, :default => true
#t.column :show_id, :integer, :null => false # added by the exclusivity
			t.column :published_datetime, :timestamp, :null => true #overrides the created_at
			t.column :comment_count, :integer, :null => false, :default => 0
      t.timestamps
    end
		# adds the hint and expiration fields to the stub class
		add_stub_fields( "Episode" )
		add_order_with_exclusivity( 'Episode', :acts_as_ordered_order, :show_id )
  end

  def self.down
    drop_table :episodes
  end
end
