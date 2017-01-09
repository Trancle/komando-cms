module CW
module Pagination

class InvalidColumnName < StandardError
end

module Model

# Simple Pagination of an Active Record Model (2.3.*)
#
# This Pagination Model represents a single Active Record model class. Ideally, it's used to paginate objects of a single model, though, you can cleverly model multiple models, too.
#
# Why not will_paginate?
#
# Well, will_paginate bugs me. Plain and simple. They're putting pagination configuration in the model, and that's just wrong. This class is much cleaner and more flexible ;). If you want to write a subclass, you can paginate practically anything in any framework. I merely provide the ActiveRecord framework here because I really needed it.
#
# Example use:
#  Let's suppose that you have a User model in your application and database: User. You want to list your Users by last then first name.
#  You'll, of course, be using your list action in your UserController at path: /users/list. Here's an example:
#
# class UserController < ApplicationController
#		def list
#			@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'User', CW::SortOrder.asc('last').asc('first'), {}, 10 )
#		end
# end
#
#	Feel free to do includes to make the namespacing a little more friendly.
#
# The above will give you a paginated listing of Users, sorted by last, then first name. Each page will contain at least 1, but at most 10 users. By default, the current page query variable is called 'page'. You can alter this by adding another argument to the end of the instantiation call (useful for collisions).
#
# In your view, you can use the pagination helper provided to display your page numbers or roll your own. For now, I'll assume you've used the helper. Here's what your view for /users/list might look like:
#
#	<h1>User list</h1>
#
#	<% unless @pagination.empty? %>
# <%= cw_pagination_page_selector( @pagination ) %>
#	<ul>
#	<% @pagination.each do |user| %>
#		<li><%= h user.last %>, <%= h user.first %></li>
#	<% end %>
#	</ul>
# <%= cw_pagination_page_selector( @pagination ) %>
#	<% else %>
#		<p>No users! Why not make one?</p>
#	<% end %>
# 
#	As you can see, this model and the helpers make pagination pretty trivial. 
#
class ActiveRecord < ::CW::Pagination::Model::ActionController


	# Class model (string) that results will be composed of
	attr_reader :item_model_klass

	# Hash to be passed to Model.find(:all, query), but does NOT contain an order key
	attr_accessor :query

# A CW::SortOrder class
	attr_reader :order

# Columns that are allowed explicityly, thereby overriding the column enforcement
	attr_accessor :explicitly_allowed_columns

# Join accessor
	attr_reader :table_join_accessors

	# The controller that is generating this model




# Create a simple pagination
#
# Arguments:
#		controller: (ActionController) the ActionController with which this model will be used. It must be the instantiated model handling the request that will render the paginated objects (you can't instantiate one just to pacify it)
#		item_model_klass: (String) the model class name of the objects that you're paginating. We will perform a constantize and no sanitization is checked, so be sure your value is either sanitized or hard-coded
#		order: (CW::SortOrder) An order specification
#		query: (Hash) the same ActiveRecord query constructs used in Base.find. Example: User.find(:all, {:order => 'first desc, id asc'	}). The 2nd argument given to User.find is the query we're expecting.
#		items_per_page: (int) The maximum number of items to display on each page
#		page_number_param_name: (String) The query or form variable parameter name to use as the indication of the current page
#		page_number_param_name: (Array<String>) The columns specified in the orderp are limited to what's in the model. So if you want to look up columns that aren't in the model (say, from a join), you can add them here to prevent the pagination class from rejecting columns it believes to be a SQL injection attack
	def initialize( controller, item_model_klass, orderp = nil, pquery = {}, items_per_page = 50, page_number_param_name = 'page', pexplicitly_allowed_columns = [] )
		super controller, items_per_page, page_number_param_name
		@item_model_klass = item_model_klass
		@query = pquery.dup
		@query.delete(:order) # even if they specified it, drop it
# We'll also perform the validation to prevent malicious users from messing with our database
# SECURITY: PARSE OUT BAD COLUMNS
		@explicitly_allowed_columns = pexplicitly_allowed_columns
		self.order = orderp
		@table_join_accessors = {}
	end

	def item_class
		@item_model_klass.constantize
	end
	protected :item_class


# Set Ordering
#
# Allows the programmer to set a custom ordering. This is the same call used in the constructor.
#
#	Arguments:
#		o: (CW::SortOrder) The order you want to sort this set of paginated items. Don't worry about specifying the complete name for a column name, that will be provided to you automatically so go query crazy.
#
# Raises:
#		CW::Pagination::InvalidColumnName if any column given in the Order class does not match one in the ActiveRecord class provided to this class. This is for your own protection.
#
# Returns:
# 	Nothing (nil)
	def order=( o )
		@order = o
	end


	def items_on_page( page_number )
		raise ArgumentError.new( "Page number: #{page_number}, is out of range." ) if !valid_page_number?( page_number ) and !count_pages.eql?(0)
		return [] if count_pages.eql?(0)
		# set the page number to 0-based index, then multiply by items_per_page
		offset = ( page_number - 1 ) * items_per_page

		item_class.find( :all, prep_query_for_find( self.query.dup ).merge( { :limit => items_per_page, :offset => offset, :order => order_with_valid_columns.to_s } ) )
	end

	def prep_query_for_find( q )
		if q.has_key?:distinct
			q[:select] = 'DISTINCT(' + q[:distinct] + ')'
			q.delete(:distinct)
		end
		q
	end

# Ordering SQL String
#
# Creates a SQL string to define the order based on the CW::SortOrder class data
	def order_with_valid_columns
		raise_on_invalid_column
		self.order
	end
	protected :order_with_valid_columns



# Item Number
#
# Gets the item number of the object passed to the function by cleverly using the conjunctive and disjunctive constraints to count fields.
#
# The idea is to build a recursively scoped search such that successive ordering constraints can be used as counting constraints to ascertain an ordering number
#
# Suppose table users ( first, last, age )
#
# Suppose you have them paginated by last, first, age: ascending, ascending, descending. A SQL Query to order such results would appear thusly: SELECT * FROM users ORDER BY last, first, age DESC
#
# Suppose ordered table:
#
# | first | last | age |
# | a     | a    | 20  |
# | b     | a    | 20  |
# | a     | b    | 30  | <= age has ordered uniquely
# | a     | b    | 20  | *
# | b     | b    | 20  | **
# | c     | b    | 20  |
# | r     | z    | 20  |
#
# When building a query to count the number of records before * or even **, we must consider that each constraint will globally eliminate rows from the selection. We don't want this as it will decrease our reported rank for the item. Instead, we must build the results up and include groups that can be included as a whole.
#
# Let's try to get where "*" is ranked.
#
# So, our first attempt to count will be:
# 	SELECT count(*) FROM users WHERE ( last < 'b' )
#
# That will return 2, as there are 2 records with a last name that is less that 'b'. In order to "expand" our search, we need to now include the secondary ordering constraint, the first name:
#
#		SELECT count(*) FROM users WHERE ( last < 'b' OR ( last = 'b' AND ( first < 'a' ) ) )
#
# Our where clause is getting slightly complex, now. We have to nest in order to ensure that we include the results from a previous constraint, while adding a very limited number of results. Take caution, we cannot simply do ( last <= 'b' ) as this will include results that we are not interested in. Once they are included in the set, we can no longer filter by that constraint. We must, instead, break the constraint into successive groups of "for sure" records and "maybies." Our first disjunctive is our "for sure" set. We know that we'll be including all records with a last name less than the one we're looking for. But we MIGHT (maybe) include all last names that equal our search object. Therefore, we now say: "I've included all the last names less than the one I'm looking for, now I'm going to add last names equal to the one I'm looking for but only if the firstname is less than the one I'm looking for". If you wanted to only have 2 ordering constraints, you could, at this point, search for first names <= 'a'. The final ordering condition can always include the "or equal to" operator. However, to account for age ordering, we need 1 more level of "for sure" and "maybe" inclusions:
#
#		SELECT count(*) FROM users WHERE ( last < 'b' OR ( last = 'b' AND ( first < 'b' OR ( first = 'b' AND age >= 20 ) ) ) )
#
# That will select all rows based on the ordering constraints without having to manually return a set of values and parse them in ruby (or any language, for that matter). This will always return a 1-based index of the item number in the set.
#
# The recursive structure for this is:
#		SELECT count(*) FROM tbl WHERE ( col_1 op_1 val_1 OR ( col_1 = val_1 AND ( col_2 op_2 val_2 OR ( col_2 = val_2 AND... ( col_n op_n= val_n ) ) ) ) )
#
# op_i i the ordering operation for that particular ordering constraint, i. For example, first name is constraint #2, and is ordered ascending. Therefore, the operation is "<" and only first names less than the one given will be a "sure thing."
#
# Now, this leaves you with 1 end case: the tie. Yes, even with all this there can be ties and the database is left to chose which order it goes. My advice, don't let it chose. Always include an ID order at the end of your ordering constraints. IDs are guaranteed to be unique and will, therefore guarantee you a unique ordering. Failure to do this MAY (not always) result in a perfect, over, or under count. It can be off as many identically ordered rows you have for the object for which you are searching
#
# Arguments:
#		object: (Varies) the item in the list for which you want to ascertain it's position in the list of all paginated items
#
# Raises:
#		InvalidColumnName if one or more columns that we're sorting upon does not exist in the database schema.
#
# Returns:
#		(int) The position of the object using a 1-based index
	def item_number( object )

		orderconds = item_number_conditions( object )

		u = query.dup
		u[:conditions] = orderconds.done

		# Use Active Record to count all items before the one we want
		item_class.count( prep_query_for_count( u ) )

	end

	def prep_query_for_count( q )
		q = q.reject{|k,v| k.eql?(:limit) or k.eql?(:offset) }
		if q.has_key?:distinct
			q[:select] = q[:distinct]
			q[:distinct] = true
		else
			q.delete(:select)
		end
		q
	end

	# Generate Active Record conditions
	def item_number_conditions( object )
		# nothing to do: no order specified
		return {} if order_with_valid_columns.nil?

		s = ''
		v = []

# First, we'll start with the last and we'll build our query from the inside out
		ordering = order_with_valid_columns.reverse
# End case: the last query:
		o = ordering.shift
		if o
			column = o.first
			direction = o.last
			s = "( #{column} #{order_to_sign( direction )}= ? )"
			if table_join_accessors.has_key?( column )
				v << table_join_accessors[column].call( object )
			else
				v << object.send( column )
			end
		end

# Now, the rest of the clauses are built to include all previous clauses
		ordering.each do |column, direction|
			s = "( #{column} #{order_to_sign( direction )} ? OR ( #{column} = ? AND #{s} ) )"
			if table_join_accessors.has_key?( column )
				v << table_join_accessors[column].call( object )
				v << table_join_accessors[column].call( object )
			else
				v << object.send( column )
				v << object.send( column )
			end
		end

		c = CW::Condition.new( ["(#{s})"].concat(v.reverse) )
		if query.has_key?(:conditions)
			CW::Condition.new( query[:conditions].dup ).and(c)
		else
			c
		end
	end
	protected :item_number_conditions

	def order_to_sign( asc_or_desc )
		( (asc_or_desc.eql?(:desc)) ? ('>') : ('<') )
	end
	protected :order_to_sign


	def count_items
		item_class.count( prep_query_for_count( query ) )
	end

	def raise_on_invalid_column
		# reject all valid or accepted columns. All remaining are bad columns
		return if order.nil?
		invalid_column = order.columns.reject{|column| item_class.column_names.include?( column ) or @explicitly_allowed_columns.include?( column ) }
		unless invalid_column.empty?
			raise InvalidColumnName.new( "Column #{invalid_column.first} is not part of the Active Record model. This either means your column name in incorrectly specified, or you're trying to hack this application." )
		end
		nil
	end
	protected :raise_on_invalid_column

# Add Join Accessor
#
# Adds a Proc {|object|} for use with looking up columns that are on joined tables. This is ONLY useful for item_number lookups.
#
# Arguments:
#
#		column_name: (String) of the name of the column to use the proc instead of the native model's accessor
#		p: (Proc) that will be executed to look up a column's value. You will be given the object that is being looked up
	def add_join_accessor( column_name, p )
		@explicitly_allowed_columns << column_name
		@explicitly_allowed_columns.uniq!
		@table_join_accessors[column_name] = p
		self
	end

end # ActiveRecord
end # Model
end # Pagination
end # CW
