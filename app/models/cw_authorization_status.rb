class CwAuthorizationStatus

	attr_reader :uid, :errors

	
	def initialize( username )
		@uid = username
		clear_errors
	end

	def can_access_backoffice?
		raise NotImplementedError.new( "Can only query authorization with a subclass of CW::Authorization" )
	end

	def add_error( m )
		@errors << m
	end

	def clear_errors
		@errors = []
	end

	def problem_diagnostic_string
		@errors.join("\n")
	end

end
