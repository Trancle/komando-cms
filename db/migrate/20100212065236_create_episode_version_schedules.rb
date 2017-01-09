class CreateEpisodeVersionSchedules < ActiveRecord::Migration
	include CW::ScheduledVersion::Migration
  def self.up
    create_scheduled_version_table :episode_version_schedules
  end

  def self.down
    drop_table :episode_version_schedules
  end
end
