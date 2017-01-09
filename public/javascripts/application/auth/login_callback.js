var application_auth_login_callback_callbacks = new Array();
function application_auth_login_callback_add( fun, arg_array ) {
	application_auth_login_callback_callbacks.push( new Array(fun, arg_array) );
}
function application_auth_login_callback_do_callbacks() {
	application_auth_login_callback_callbacks.each( function(e) {
				try {
					e[0]( e[1] );
				} catch( er ) {
					// Skip if this function doesn't exist
				alert( er );
				}
			} );
}
