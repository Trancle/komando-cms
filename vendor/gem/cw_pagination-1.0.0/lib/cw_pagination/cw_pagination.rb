module CW
module Pagination

class PageNumberOutOfRange < StandardError
end
class ItemOutOfRange < StandardError
end
class ItemNotFound < StandardError
end

module Model

# Pagination Model
#
# Contains everything you need from the pagination method calls. This is an abstracted pagination. A bridge between the Model and the Controller. It controls how queries are performed and carried over. This is the root class.
#
# It works by performing all the calculations required based on a few methods that are fully intended to be overridden by child classes. This model is a shell and does not contain any data that is going to be modeled. It merely stores the configuration required to obtain the information when needed. See the "Simple" model below for a better example of how it can be used
#
# Writing your own subclasses:
#
# You can pagination almost anything in anything using this base class and a subclass based on this base class. They key is that my pagination class has done a lot of the routine work for you. You need only overwrite 4 instance methods. Yes, 4 (four).
#
# * items_on_page: This is where you come in. What's on the page?
# * count_items: The total number of items accross all pages
# * current_page_number: The class needs to know what page it's currently on. Some automatic convenience methods rely on it.
# * item_number: This is an advanced function for looking up an object's number in the pagination scheme. It's needed only for determining the page number an object is on. If you don't care, you can skip this one.
#
# All the other cool stuff is ascertained from those 4 methods. 
class Base
# The maximum number of items that can appear on any given page
	attr_accessor :items_per_page

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
#		items_per_page: (int) The maximum number of items to display on each page
#		page_number_param_name: (String) The query or form variable parameter name to use as the indication of the current page
	def initialize( items_per_page = 50 )
		@items_per_page = items_per_page
	end

# Valid Page Number?
#
# Tests if the given page number is valid
#
# @param[in] page_number a numeric page number to be tested
# @returns true if the page is within the valid range, false if not (does not auto-correct)
	def valid_page_number?( page_number )
		1 <= page_number and page_number <= count_pages
	end


# Count Pages
#
# Calculates the total number of pages required based on the items_per_page
#
# @returns total number of pages required to display all items in the set
	def count_pages
		full_pages = count_full_pages
		if full_pages * items_per_page < count_items
			return full_pages + 1
		else
			return full_pages
		end
	end

# Page Number for Item Number
#
# Given an item number, calculates the page upon which it will appear. This is the same logic as count_pages, but with a different target point. count_pages uses the last item to count the number of pages. The last item is always on the last page (full page or not)
#
# Keep in mind, this is NOT the item VALUE, but rather the item's place in the grand ordering of things
#
# @param[in] item_number, item number: [1..count_items]
# @returns the page number upon which the item number is to be found: [1..count_pages]
# @raises CW::Pagination::ItemOutOfRange when the item_number is beyond the count_items number (out of range)
	def page_number_for_item_number( item_number )
		raise ItemOutOfRange.new if item_number > count_items
		fp = item_number / items_per_page
		if fp * items_per_page < item_number
			return fp + 1
		else
			return fp
		end
	end

# Count Full Pages
#
# Calculates the number of full pages (pages that have items equal to items_per_page
#
# @returns the number of pages that contain the maximum number of items per page (complete/full page)
	def count_full_pages
		count_items / items_per_page
	end

# Count Items on Last page
#
# Calculates the number of items that are contained on the last page
#
# @returns the number of items on the very last page
	def count_items_on_last_page
		c = count_items % items_per_page
		if c.eql?(0)
			return items_per_page
		else
			return c
		end
	end

# Page number of item
#
# Calculates the page upon which the given item can be found
#
# @param[in] object The object for which to determine the page
# @returns the page number [1..count_pages]
	def page_number_of_item( object )
		page_number_for_item_number( item_number( object ) )
	end


# Items for current page
#
# Obtains the items for the page that is determined to be the page that you're currently on. It just saves you the step of having to actually figure out the page and request the items for that page.
#
# Arguments:
#		none
#
# Raises:
#		PageNumberOutOfRange if the current_page_number returns an invalid page number
#
# Returns:
#		(Array) An array of objects that have been paginated, the type depends on the subclass used to paginate
	def items_for_current_page
		cp = current_page_number
		raise PageNumberOutOfRange.new( "Page Number: #{cp} is out of range: 1..#{count_pages}" ) unless valid_page_number?( cp )
		items_on_page( cp )
	end

# Each
#
# Iterates through every item in the current page, just like an array
#
# Block:
#		The process you want to perform on each item in the current page
#
# Returns:
#		(Array) of items in the current page
	def each
		items_for_current_page.each do |i|
			yield(i)
		end
	end

# Collect
#
# Iterates through every item in the current page, just like an array
#
# Block:
#		The process you want to perform on each item in the current page
#
#	Returns:
#		(Array) of whatever you choose based on the block you provide
	def collect
		items_for_current_page.collect do |i|
			yield(i)
		end
	end

# Empty?
#
# Tests to see if the current page is empty. Really only useful if your database is empty, but you should cover all cases.
#
#	Returns:
#		(boolean) of true if there are no items on the current page, false if the page contains at least 1 item
	def empty?
		count_items.eql?(0)
	end

# First?
#
# Tests if this is the first page.
#
# Returns:
#		(boolean) of true if the current page is the first page, false if it's not
	def first?
		current_page_number.eql?1
	end

# Last?
#
# Tests if this is the last page.
#
# Returns:
#		(boolean) of true if the current page is the last page, false if it's not
	def last?
		current_page_number.eql?(count_pages)
	end

# Has Next page?
#
# Tests if the current page has a page after it.
#
# Returns:
#		(boolean) true if a page (full or not) follows this page, false if there are insufficient items to create a next page
	def has_next_page?
		!last?
	end

# Has Previous page?
#
# Tests if the current page has a page before it.
#
# Returns:
#		(boolean) true if a page preceeds this page, false if this is the first page
	def has_previous_page?
		!first?
	end

# Page Numbers closest to current page
#
# Gets a range of page numbers around the current page by building out the page numbers until the maximum number of pages (not including the current page) have been included
#
#	Argument:
#		max_pages: (int) maximum number of pages in a range to return, excludes the current page
#
# Returns:
#		(Range) of page numbers (integers) of size <= max_pages + 1 as the current page will be included in the range
	def page_numbers_closest_to_current_page( max_pages )
		raise ArgumentError.new( "Max pages must be >= 0" ) unless max_pages >= 0
		r = current_page_number..current_page_number
		return r if max_pages.eql?0
		dir = :fwd
		while( r.end - r.begin < max_pages and !( r.begin.eql?(1) and r.end.eql?(count_pages) ) )
			if dir.eql?(:fwd)
				dir = :bck

				unless r.end.eql?(count_pages)
					r = r.begin..(r.end + 1)
				end
			else
				dir = :fwd

				unless r.begin.eql?(1)
					r = (r.begin - 1)..r.end
				end
			end
		end
		r
	end






# OVERRIDE METHODS BELOW



# Current page number
#
# Calculates or otherwise obtains the current page number. Makes corrections to bad page numbers
#
# @returns the current page number starting from index 1 to count_pages
	def current_page_number
		raise NotImplementedError.new
	end

# Items on Page
#
# Given a page number, return all the items that will appear on that page
#
# OVERRIDE THIS IN CHILD CLASSES
#
# @param[in] page_number, an integer representing a valid page number
# @return an array of items that are to be represented on the page requested
# @raises PageNumberOutOfRange if the page number is out of range
	def items_on_page( page_number )
		raise NotImplementedError.new
# Suggested implementor exceptions and validations
		raise PageNumberOutOfRange.new( "Page number: #{page_number}, is out of range." ) unless valid_page_number?( page_number )
	end

# Item Number of Item
#
# Determines the item number given the ordering and condition constraints. Item MUST be in the list or this method will throw a RecordNotFound exception
#
# OVERRIDE THIS IN CHILD CLASSES
#
# @param[in] object The object for which to search
# @returns The item number the object resides in [1..count_items], or an approximation if not found
	def item_number( object )
		raise NotImplementedError.new
	end

# Item Count
#
# Tallys the number of items accross all pages.
#
# OVERRIDE THIS IN CHILD CLASSES
#
# @returns the number of items in the "book" for which we're paginating
	def count_items
		raise NotImplementedError.new
	end

end # Base

end # Model

end # Pagination
end # CW
