module CW
module Pagination

module View


# Page Swath
#
# Given a pagination model and a width, will yield with all the pages around the current page in the width requested
	def self.page_swath( pagination, max_pages = 10 )
		# calculate the starting point, iterate over them
		pagination.page_numbers_closest_to_current_page( max_pages ).each do |page_number|
			yield( page_number, page_number.eql?(pagination.current_page_number) )
		end
	end

# Button to Page Tag
#
# Creates a button that goes to the page indicated and includes the preserved parameters
#
#	Arguments:
#		pagination: (CW::Pagination::Model::Base subclass) The model to get the pagination information
#		view:	(ActionView) The action view that will render the HTML code. This is requried to call Rail's helper methods for that view
#		page: (Varies) Can be a number, a string of a number. Can also be :first or :last to automatically generate the first/last page numbers, respectively. Can also be :previous and :next.
#		button_content: (String) the content of the button. The rendered button is a <button> element. If you leave this argument off, it will display the page number. Otherwise, if you want to leave it blank (why?) explicitly set this argument to an empty string
#		html_options: (Hash) rails' standard HTML tag options. Will be placed on the <form> element. By default, pagination forms use the "get" method as this allows for page crawling and indexing in search results. To override this, simply specify {:method => 'post'} as your html_options
#
# Returns:
#		A string with rendered HTML ready for inclusion in whatever you want
	def self.button_to_page_tag( pagination, view, page, button_content = nil, html_options = {} )
		case page
			when :first
				page = 1
			when :last
				page = pagination.count_pages
			when :next
				page = pagination.current_page_number + 1
			when :previous
				page = pagination.current_page_number - 1
			else
				# do nothing
		end
		html_options[:class] = 'current ' + ( html_options[:class] || '' ) if page.eql?(pagination.current_page_number)

		s = view.tag( 'form', { :method => 'get' }.merge( html_options ), true )
		s += view.tag('div', {:style => 'display:none;'})
		s += preserve_parameter_hidden_field_tags( pagination, view )
		button_content = page.to_s if button_content.nil?
		s += view.tag( 'input', { :type => 'hidden', :name => pagination.page_number_param_name, :value => page } )
		s += '</div>'
		s += view.tag( 'button' )
		s += button_content
		s += '</button>'
		s += '</form>'
		s
	end

# Jump To Page Tag
#
# The idea is to make a helper that will create a text box and a button such that entering a page number and clicking the button will jump to the page requested.
#
# Example:
# view.ehtml:
#
#	<%= jump_to_page( @pagination, self ) %>
#
# will result in:
#
#	view.html (output from application)
#
#	<form method="get" action="/controller/action/for/view">
#		<div style="display:none;">...Any preserved parameters as hidden fields...</div>
#		<div><input type="text" name="page" /></div>
#		<button>Go</button>
#	</form>
#
# Spacing and newlines have been added for readability
	def self.jump_to_page_tag( pagination, view, button_content = 'Go', html_options = {} )
		s = view.tag( 'form', { :title => 'Enter a page number and click the button to jump to that page', :method => 'get' }.merge( html_options ), true )
		s += view.tag('div', {:style => 'display:none;'})
		s += preserve_parameter_hidden_field_tags( pagination, view )
		s += '</div><div>'
		s += view.tag( 'input', { :alt => 'Enter page to which you wish to jump', :type => 'text', :name => pagination.page_number_param_name } )
		s += '</div>'
		s += view.tag( 'button' )
		s += button_content
		s += '</button>'
		s += '</form>'
		s
	end

# preserve parameter hidden field tags
#
# Creates all hidden field tags that were specified as preserved and pulls their values down into them.
#
#	Arguments:
#		pagination: (CW::Pagination::Model::Base subclass) The model to get the pagination information
#		view:	(ActionView) The action view that will render the HTML code. This is requried to call Rail's helper methods for that view
#
# Returns:
#		A string with rendered HTML ready for inclusion in whatever you want
	def self.preserve_parameter_hidden_field_tags( pagination, view )
		pagination.parameters.collect{|p,v| view.tag( 'input', { :type => 'hidden', :name => p, :value => v } ) }.join
	end


end # View

end # Pagination
end # CW
