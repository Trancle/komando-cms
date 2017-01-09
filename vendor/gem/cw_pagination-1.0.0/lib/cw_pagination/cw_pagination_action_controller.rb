require File.dirname(__FILE__) + '/cw_pagination.rb'
module CW
module Pagination
module Model

# Pagination Model for use with Rails.
#
# Like the base class, this class improves upon CW::Pagination::Model::Base (as this class is a direct subclass thereof). This class adds the ability to preserve the controller that will instantiate this class, as well as carrying over parameters for pagination between HTTP requests. This has been abstracted away from the base class to assist with testing and for greater re-use of the base class in non-rails applications. One could, theoretically, use it in a Ruby GTK application quite easily.
#
# Again, this class differs from the base as the current page is automatically ascertained by configuring this class with the controller and name of the page parameter. This class also supports preserving other paramters. This topic is explained below
#
# Preserving Parameters:
#
#	It is, at times, useful to leaverage pagination with other information. For example, if you have a list of users and want to filter them, you still want the filtered results to be paginated because there may be many results. Therefore, it's important that the pagination understand that you have data you wish to preserve between requests and it's not a good idea to use cookies for this information.
#
#	To add a parameter to preserve, simply call preserve_parameter_named with the parameter key you want to save. The helper functions provided can do the rest
class ActionController < ::CW::Pagination::Model::Base
# Controller object from the calling controller
	attr_accessor :controller

# A list (Array) of queries/form_data to be preserved between pagination requests, if available
# Preserved parameters have their values saved over to the next GET/POST call via a hidden field with the same name
# These parameters have nothing to do with pagination, but must merely come along for the ride. They're not parsed in any way. They'll be parsed from the params variable and placed in a hidden field of the same name along with each pagination button made using the helpers provided
	attr_reader :preserve_parameters

# Page Number Parameter Name
# Contains the page number parameter that holds the current page's number. For example, if the current page is 5 and the page_number_param_name is 'zim_page_number' then param['zim_page_number'] should be = 5. By default, this is just "page"
# These should be straight parameters. No nesting for simplicity and security.
#
# This setting is here in case you have a naming conflict. For example, it's possible to have pagination nested within other pagination.
	attr_accessor :page_number_param_name


# Initialize
#
# Readies the pagination class for action by setting some critical defaults
#
#	Arguments:
#		controller: (ActionController) the ActionController with which this model will be used. It must be the instantiated model handling the request that will render the paginated objects (you can't instantiate one just to pacify it)
#		items_per_page: (int) The maximum number of items to display on each page
#		page_number_param_name: (String) The query or form variable parameter name to use as the indication of the current page
	def initialize( controller, items_per_page = 50, page_number_param_name = 'page' )
		super items_per_page
		@controller = controller
		raise ArgumentError.new( "items_per_page must be a whole number" ) unless items_per_page.is_a?(Integer)
		raise ArgumentError.new( "items_per_page must be >= 1, but got #{items_per_page}" ) unless items_per_page >= 1
		@preserve_parameters = []
		@page_number_param_name = page_number_param_name
	end


# Current page number
#
# Calculates or otherwise obtains the current page number. Makes corrections to bad page numbers
#
# @returns the current page number starting from index 1 to count_pages
	def current_page_number
		# parameter is missing or empty
		if @controller.params[page_number_param_name].nil? or @controller.params[page_number_param_name].empty?
			# current page is therefore, 1
			return 1
		else
			# page variable is found
			as_int = @controller.params[page_number_param_name].to_i
			unless valid_page_number?( as_int )
				if as_int < 1
					# int is not a number, or it's less than 1, assume they mean page 1
					return 1
				else
					return count_pages
				end
			else
				return as_int
			end
		end
	end


# Preserve Parameter
#
# Tells the pagination helpers to preserve params between pagination navigation. This is useful for flipping between pages of filtered results
#
# Arguments:
#		name: (String) query or form key name to include in page navigation requests. For example, if you're paginating a list of users and want to filter by first name and your query structure appears thusly: "/users/list?filter_first=chris", then you'd specify: "filter_first" as a preserve paramater name. That value will be propagated with each page button navigation
	def preserve_parameter_named( name )
		@preserve_parameters << name
	end

end # ActionController
end # Model
end # Pagination
end # CW
