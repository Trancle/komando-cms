class UserIdentified < User
	has_many :user_input_ban_schedules, :class_name => 'UserInputBanScheduleRange', :foreign_key => :exclusivity_id, :dependent => :destroy
	has_many :episode_comments, :foreign_key => 'user_id', :dependent => :destroy
end
