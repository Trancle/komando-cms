class CreateUserInputBanScheduleRanges < ActiveRecord::Migration
	include CW::MuExDateRange::Migration
  def self.up
    create_date_range_table :user_input_ban_schedule_ranges
  end

  def self.down
    drop_table :user_input_ban_schedule_ranges
  end
end
