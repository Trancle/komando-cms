class UserAnonymous < User

	# override the username, as we'll never have one.
	def username
		'Anonymous'
	end

	# anonymous users are always enabled, otherwise, no one but logged in users could do anything
	def enabled
		true
	end

end
