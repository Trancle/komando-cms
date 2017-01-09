function episode_comment_new_comment_form_id() { return '#new-episode-comment-form';
}
function episode_comment_new_comment( episode_id, parent_comment_id ) {
	if( parent_comment_id !== null ) {
		$( '#episode_comment_parent_comment_id' ).val( parent_comment_id );
	}
	$('#new_episode_comment_submit_container').hide();
	$('#new_episode_comment_submit_spinner').show();
	$.post( '/comment/create_episode_discussion/' + episode_id + '.json', $(episode_comment_new_comment_form_id()).serialize(), null, 'json' ).done( function(data,textStatus) {

		if( data.success ) {
			$( '#new-episode-comment' ).hide();
			/* update the comments */
			episode_comment_refresh_comments( episode_id );
			episode_comment_new_comment_dismiss();
		} else {
			// wipe old errors
			$('#new-episode-comment-errors').children().remove();
			
			var container = document.createElement('div');
			var list = document.createElement( 'ul' );
			var li;
			$.each( data.errors, function(i,errors_for_field) {
						li = document.createElement( 'li' );
						$(li).text( errors_for_field[0] + ' ' + errors_for_field[1] );
						$(list).append(li);
					} );
			var h2 = document.createElement('h2');
			$(h2).html('Errors for Comment');
			$(container).append( h2 );
			$(container).append( list );
			$('#new-episode-comment-errors').append( container );
			$('#new-episode-comment-errors').show();
		}

	} ).always( function( data, textStatus, errorThrown ) {
		$('#new_episode_comment_submit_container').show();
		$('#new_episode_comment_submit_spinner').hide();
	} );
}
function episode_comment_new_comment_dismiss() {
	/* clear the form */
	$(episode_comment_new_comment_form_id())[0].reset();
	/* get rid of the error messages */
	$('#new-episode-comment').hide();
	$('#new-episode-comment-errors').hide();
	$('#new_episode_comment_submit_container').show();
	$('#new_episode_comment_submit_spinner').hide();
	$('#episode_comment_parent_comment_id').val( '' );
}
function episode_comment_refresh_comments( episode_id ) {
	$.get( '/watch/comments/' + episode_id ).done( function(data) {
		$('#comments').html( data );
} );
}
