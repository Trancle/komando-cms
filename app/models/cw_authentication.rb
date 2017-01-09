class CwAuthentication

	attr_reader :credentials, :errors

	def self.authentication_mechanism; CwAuthenticationManagerConfig.authentication_mechanism; end

	def initialize( credentials )
		@credentials = credentials
		clear_errors
	end

	def is_authenticated?
		raise NotImplementedError.new( "Can only authenticate with a subclass of CW::Authentication" )
		false
	end

	def uid
		raise NotImplementedError.new( "Can only authenticate with a subclass of CW::Authentication" )
		false
	end

	def username
		raise NotImplementedError.new( "Can only authenticate with a subclass of CW::Authentication" )
		false
	end

	def email
		raise NotImplementedError.new( "Can only authenticate with a subclass of CW::Authentication" )
		false
	end

	# If something went wrong with authentication, the system will call this function and insert the resulting string into the log file
	def problem_diagnostic_string
		if has_error?
			@errors.join("\n")
		else
			'No errors reported'
		end
	end

	def add_error( m )
		@errors << m
	end

	def clear_errors
		@errors = []
	end

	def has_error?
		!@errors.empty?
	end

end
