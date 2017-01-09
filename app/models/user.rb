require 'bcrypt'
class User < ActiveRecord::Base
  include BCrypt
	validates_presence_of :username
	validates_length_of :username, :in => 1..256, :allow_nil => true
	validates_uniqueness_of :username, :allow_nil => true
	validates_presence_of :enabled


  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  # get the user if password matches, nil if not found or password does not match
  def self.authenticate_admin_user( email, password )
    u = self.first( :conditions => ['email = ? AND type = \'UserAdministrator\'',email] )
    if u and u.password == password
      u
    end
  end

	def self.validate_credentials( credentials = {} )
		# can't validate credentials without a username
		return false unless credentials.key?(:username)
		# use the stub to check if this user is logged in
		if authentication_successful
			true
		else
			false
		end
	end

	def self.find_user_with_username( username )
		# can't find a user without a username, anonymous :-)
		return AnonymousUser.new() if username.nil? or username.empty?

		# if not anonymouse, then user MUST exist, otherwise, return nil:
		# returns nil if not found. 
		User.find_by_username( username )
	end

	def user_input_banned?( t = Time.now.utc )
		return true # only allow identified users
	end

	# Default: applies to all users unless explicitly overridden
	def can_watch_episode?( episode, t = Time.now.utc )
		episode.free?( t ) and episode.available?( t )
	end

	def can_comment?( t = Time.now.utc )
		false
	end

	PUBLIC_RENDER_OPTIONS = { :only => [:username,:id] }.freeze

	def to_public_xml( opts = {} )
		self.to_xml( opts.merge( PUBLIC_RENDER_OPTIONS ) )
	end

	def to_public_json( opts = {} )
		self.to_json( opts.merge( PUBLIC_RENDER_OPTIONS ) )
	end

end
