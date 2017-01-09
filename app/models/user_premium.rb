class UserPremium < UserIdentified
	def user_input_banned?( t = Time.now.utc )
		# Administrators are never banned, but premium users can be
		s = UserInputBanSchedule.new( self.id )
		s.includes?( t )
	end

	# premium users may only watch available episodes, but can watch free and non-free
	def can_watch_episode?( episode, t = Time.now.utc )
		episode.available?( t )
	end

	def can_comment?( t = Time.now.utc )
		!user_input_banned?( t )
	end

end
