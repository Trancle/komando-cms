module CommentHelper

	def episode_comment_type
		@controller.action_name.match(/new_episode_comment_(.+)_report/)[1].sub('_','-')
	end

end
