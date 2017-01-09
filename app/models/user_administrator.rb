class UserAdministrator < UserIdentified
	has_many :link_user_with_user_roles, :foreign_key => 'user_id', :dependent => :destroy
	has_many :user_roles, :through => :link_user_with_user_roles


		# Administrators are never banned, but premium users can be
	def user_input_banned?( t = Time.now.utc ); false; end


	# administrators can always view episodes, regardless of time
	def can_watch_episode?( episode, t = Time.now.utc )
		true
	end

	def can_comment?( t = Time.now.utc )
		true
	end

end
