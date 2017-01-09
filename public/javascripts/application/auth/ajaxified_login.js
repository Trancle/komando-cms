function application_ajaxified_login_submit( form_id ) {
	new Ajax.Request( '/auth/login.json', {
			method: 'post',
			postBody: $(form_id).serialize(),
			onSuccess: function( transport ) {
				try {
					/* This does not mean login succeeded, we must check for that */
					if( transport.responseJSON.did_login ) {
						// Login worked
						application_ajaxified_login_container().hide();
						// call the login callback, if it exists
						if( application_auth_login_callback_do_callbacks != undefined ) {
							application_auth_login_callback_do_callbacks();
						}
					} else {
						// bad username or password
					}
				} catch( e ) {
					/* Exceptions are not reported, but we can catch them here */
				}
			},
			onFailure: function( transport ) {
				// Unable to contact the server: tell them to try again later
			},
			onCreate: function() {
				// Show the waiting screen
				$('ajaxified-login-submit').hide();
				$('ajaxified-login-spinner').show();
			},
			onComplete: function() {
				// Unshow the waiting screen
				$('ajaxified-login-spinner').hide();
				$('ajaxified-login-submit').show();
				// always clear the password
				$('password').value = '';
			}
	}
			);
}
function application_ajaxified_login_container() {
	return $('ajaxified-login-container');
}
