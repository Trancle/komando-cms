class UserDrop < BaseDrop

	def initialize( user, controller, time = Time.now.utc, options = {} )
		@user = user
		@controller = controller
		@time = time
		@options = options
	end

	def errors
		@user.errors.full_messages
	end

  def username
    @user.username
  end

  def email
    @user.email
  end

end
