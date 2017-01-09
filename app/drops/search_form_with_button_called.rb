module SearchFormWithButtonCalled

	def search_form_with_button_called( form, name )
		# replaces the default form submit button name with one of their choosing
		form.sub('value="go"','value="'+name+'"')
	end

end
