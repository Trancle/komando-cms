class CreateEpisodePublishScheduleDates < ActiveRecord::Migration
	include CW::MuExDateRange::Migration
  def self.up
    create_date_range_table :episode_publish_schedule_dates
  end

  def self.down
    drop_table :episode_publish_schedule_dates
  end
end
