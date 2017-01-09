function episode_comment_new_tag( episode_id, indicator_id, tag_field_id, tag_list_id ) {
	$(indicator_id).show();

	tags = $F(tag_field_id);
	$(tag_field_id).value = '';

	new Ajax.Request( '/comment/create_tag_ajax/' + episode_id, {
postBody: 'tags=' + tags,
onSuccess: function(transport) {
	$(tag_list_id).update( transport.responseText )
	$(indicator_id).hide();
},
onFailure: function(transport) {
	$(indicator_id).hide();
}
			} );
}
