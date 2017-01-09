class CreateRouteAliases < ActiveRecord::Migration
	include CW::MuExDateRange::Migration
  def self.up
		# exclusivity_id is a string... MAGIC! look up by string, not integer-based id
    create_date_range_table :route_aliases, :text do |t|
			t.column :alias_to, :text, :null => false
			t.column :enabled, :boolean, :null => false, :default => true
			# HTTP result code determined by end_at. Anything prior to start doesn't trigger this alias
      t.timestamps
    end
  end

  def self.down
    drop_table :route_aliases
  end
end
