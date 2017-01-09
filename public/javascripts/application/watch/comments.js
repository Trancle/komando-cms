function application_watch_comments_update_comments_on_login( args ) {
	// change the link to display as logged in
	$('#new-episode-comment-login-to-comment').html('<a href="#" onclick="$(\'new-episode-comment\').show(); return false;">comment</a>');
	episode_comment_refresh_comments( args[0] );
	
}
