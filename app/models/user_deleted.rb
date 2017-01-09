# indicates that this user has been deleted. They should NOT be saved
class UserDeleted < User
	before_save :mark_read_only

	def mark_read_only
		self.errors.add_to_base( 'Deleted users cannot be saved into the database again' )
		false
	end

	def username
		'User deleted'
	end
	def email
		'User deleted'
	end

	def id
	  nil
	end
end
