class LoginFormDrop < BaseDrop

	def initialize( view, action, username, redirection, remember_me, login_error_message = nil )
		@view = view
		@error_message
		@error_message = login_error_message
		@username = username
		@redirection = redirection
		@remember_me = remember_me
    @action = action


	end

# A plain string with the login error message (returned in the event login fails for normal reasons such as a bad username or password
	def error_message
		@error_message || ''
	end

	def error_message?
		!@error_message.nil? and !@error_message.empty?
	end

	def redirection?
		@redirection
	end
	def remember_me?
		@remember_me
	end

	def open
		out = @view.form_tag( { :controller => 'auth', :action => @action } )
		out << '<div style="display:none;">' + hidden_field_tag( 'r', ( redirection? ? @redirection : '' ) ) + '</div>'
		out
	end

	def username_text_field
		text_field_tag( username_field_id, @username )
	end
	def password_password_field
		password_field_tag( password_field_id )
	end
	def remember_me_check_box_field
		check_box_tag( remember_me_field_id, '1', ( remember_me? ? @remember_me : false ), :class => 'checkbox' )
	end

	def username_field_id
		'username'
	end

	def password_field_id
		'password'
	end

	def remember_me_field_id
		'remember_me'
	end

	def close
		"</form>"
	end

end
