/* Performs reporting on a comment */
function episode_comment_report_report_comment( comment_id, as_type, indicator_id, hide_id, update_id ) {
	$(hide_id).hide();
	$(indicator_id).show();

	new Ajax.Request( '/comment/create_episode_comment_report/' + comment_id + '.json', {
				postBody: 'episode_report[reason]='+as_type,
				onSuccess: function(transport) {
					if( transport.responseJSON.size() == 0 ) {
						$(update_id).update( '<p>reported!</p>' );
					} else {
						$(update_id).update( '<p>failed!</p>' );
					}
					$(update_id).show();
					$(indicator_id).hide();
				},
onFailure: function( transport ) {
	$(update_id).update( 'There was an error reporting this comment' );
					$(indicator_id).hide();
	$(update_id).show();
}
			} )
}
