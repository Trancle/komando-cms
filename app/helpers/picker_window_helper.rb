module PickerWindowHelper

	# named: is the ID name of the picker window that is displayed via the library
	# put_result_to_id: is the form field that is updated when an item is selected
	# ajax_list_uri: is the URI pointing to where you can get a JSON list of items
	# ajax_list_metadata_uri: is the URI pointing to where you can get a JSON object containing count key that indicates the number of items in the ajax_list_uri above
	def picker_window( named, ajax_list_uri, ajax_list_metadata_uri, picker_window_item_detail_display_klass_name, onPickHandler, pagination_query_string, window_title = "Picker" )
		r =  "<div id=\"#{named}\" class=\"cw-picker-window-container\" style=\"display: none;\">"
		r += '<div class="close_button" title="Close">' + link_to_function( 'X', "$('#{named}').hide()" ) + '</div>'
		r += '<h1 class="cw-picker-window">' + window_title + '</h1>'
		r += "<div id=\"#{named}-picker-window-list\" class=\"scrolled-list\"></div>"
		r += '<div>' + spinner_named( named + '_spinner' ) + '</div>'
 		r += javascript_tag( "var cw_picker_window_var_#{named} = new PickerWindow('#{named}','#{ajax_list_uri}','#{ajax_list_metadata_uri}','" + pagination_query_string + "','#{picker_window_item_detail_display_klass_name}'); cw_picker_window_var_#{named}.onPick = #{onPickHandler};" )
		r += '<div class="cw-picker-window-navigation"><a href="#" id="' + named + '_nav_previous">&lt;</a> - <a href="#" id="' + named + '_nav_next">&gt;</a></div><script type="text/javascript">$("' + named + '_nav_previous").click( function() { cw_picker_window_var_' + named + '.prev_page(); } ); $("' + named + '_nav_next").click( function() { cw_picker_window_var_' + named + '.next_page(); } );</script>'
		r += '</div>'

		r
	end

end
