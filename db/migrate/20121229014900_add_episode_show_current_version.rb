=begin

2012-12-28 Christopher Wojno

This migration marks the removal of the episode scheduled version over-engineering. Here's the plan. I'm going to keep the versions. These are useful. However, Episodes have never needed to be scheduled to be changed. They just get changed. Shows are different. Shows get season updates and the like and those should be schedule-able, but episodes are so quick and disposable, that it's too cumbersome to create episodes with versions. Additionally, the number of shows is small compared to episodes. Episode look ups are hindered by an additional 2 checks of which version based on dates and exclusions. Therefore, only episodes will have their versions removed.

Page layouts shall also retain their versions as these are useful to schedule seasonal or thematic changes.

1. Create the new infrastructure for selecting the current version of an episode.
1.1. Add a current_version_id field to episodes for fast look ups. If this is null, then there is no current version. Pretend that this episode does not exist, publicly.
1.2. Re-configure episode creation/updating to disallow scheduling. Add a button to immediately make the selected version the published version, replacing any version that was already in place
2. Migrate the database
3. Clean up
3.1. Remove stub and version code
3.2. Remove the episode version tables:
 * episode_version_schedule_dates
 * episode_version_schedules

=end

class AddEpisodeShowCurrentVersion < ActiveRecord::Migration
  def self.up
    add_column :episodes, :current_version_id, :integer

    # set the current version of each episode
    Episode.all.each do |episode|
      ev = episode.scheduled_version_current
      if ev
        episode.current_version_id = ev.id
        episode.save!
      end
    end

    # This is migration part 1. The next migration, removal of the old cruft, must occur after this migration has run and the code has been updated.
  end

  # We're deleting data, we cannot go back...
  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
