=begin

2012-12-28 Christopher Wojno

This migration completes the removal of episode versioning-over-engineering.

=end

class RemoveEpisodeVersion < ActiveRecord::Migration
  def self.up
    drop_table :episode_version_schedule_dates
    drop_table :episode_version_schedules

    # This is migration part 1. The next migration, removal of the old cruft, must occur after this migration has run and the code has been updated.
  end

  # We're deleting data, we cannot go back...
  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
