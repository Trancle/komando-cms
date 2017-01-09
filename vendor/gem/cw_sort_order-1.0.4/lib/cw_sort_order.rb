# Copyright 2011 Christopher Wojno

module CW

# Specifies Sorting Order
#
# Provides a clean, programmatic way to express how columns are to be sorted. It also lets you build them in your models and re-use the ordering without having to put them into controllers so you can use them across many controllers. Or you can stick them in controllers and use them across actions. Or you can YAMLize them and put them into databases... Why? I dunno, sounds like a cool idea.
#
# So, this class doesn't actually DO any sorting. It merely represents a cascading sorting order. Think of it like an ORDER BY clause in a SQL Query. It doesn't actually sort, but tells whatever classes that use it how to sort.
#
# Example, say you had a users table with fields: first, last, age. If you want to order by last name, then first name, then oldest to youngest, create an order thusly:
#
# CW::SortOrder.new.asc('last').asc('first').desc('age')
#
# OR
#
# CW::SortOrder.up('last').up('first').dn('age')
#
# OR
#
# CW::SortOrder.new + 'last' + 'first' - 'age'
class SortOrder
	attr_reader :ordering

# Creates a new SortOrder, with nothing sorted
	def initialize
		@ordering = []
	end

# Ascending Constructor
#
# Creates a new SortOrder class with an ascending sort on the given column
#
#	Arguments:
#		column_name: (String) representing the field or column upon which to perform the order
	def self.asc( column_name )
		self.new.asc( column_name )
	end
	class << self
		alias :up :asc
	end

# Descending Constructor
#
# Creates a new SortOrder class with an descending sort on the given column
#
#	Arguments:
#		column_name: (String) representing the field or column upon which to perform the order
	def self.desc( column_name )
		self.new.desc( column_name )
	end
	class << self
		alias :down :desc
		alias :dn :desc
	end

# Append Ascending Column
#
# Appends (adds) a sorting order to an existing set of sorting orders. The appended order is ascending.
#
#	Arguments:
#		column_name: (String) representing the field or column upon which to perform the order
#
#	Returns:
#		self: (CW::SortOrder)
	def asc( column_name )
		push( column_name, :asc )
	end
	alias :up :asc

# Append Descending Column
#
# Appends (adds) a sorting order to an existing set of sorting orders. The appended order is descending.
#
#	Arguments:
#		column_name: (String) representing the field or column upon which to perform the order
#
#	Returns:
#		self: (CW::SortOrder)
	def desc( column_name )
		push( column_name, :desc )
	end
	alias :down :desc
	alias :dn :desc

# Append Descending Column
#
# Appends (adds) a sorting order to an existing set of sorting orders. The appended order is descending.
#
#	Arguments:
#		column_name: (String) representing the field or column upon which to perform the order
#
#	Returns:
#		self: (CW::SortOrder)
	def -( column_name )
		desc( column_name )
	end

# Append Ascending Column
#
# Appends (adds) a sorting order to an existing set of sorting orders. The appended order is ascending.
#
#	Arguments:
#		column_name: (String) representing the field or column upon which to perform the order
#
#	Returns:
#		self: (CW::SortOrder)
	def +( column_name )
		asc( column_name )
	end

# Push
#
# Appends a sorting order very literally. This method is NOT safe and is for internal use (or child class use) only.
#
#	Arguments:
#		column_name: (String) representing the field or column upon which to perform the order
#		direction: (Symbol) [:asc|:desc] representing the direction to sort the given column_name. :desc to sort descending, :asc to sort ascending.
#
#	Returns:
#		self: (CW::SortOrder)
	def push( column_name, direction )
		@ordering << { column_name => direction }
		self
	end
	protected :push

# Size
#
# Returns how many sorting orders there are (columns).
#
# Returns:
#		(Integer) The number of columns represented. Note, if you add the same column twice, this class is NOT smart enough to figure it out.
	def size
		ordering.size
	end

# Accessor
#
#	Gets an ordering pair of type: [column_name,:direction]
#
#	Arguments:
#		i: (Integer) the index of the ordering pair. Should be 0..(size - 1)
#
# Returns:
#		The ordering pair as a 2-element array. The first element is the column name, the second is either :asc or :desc representing ascending and descending sort orders, respectively.
	def [](i)
		ordering[i]
	end

# Column Name At
#
#	Gets the name of the column at the index position given
#
#	Arguments:
#		i: (Integer) the index of the ordering pair. Should be 0..(size - 1)
#
# Returns:
#		The column name at the index provided.
	def at(i)
		ordering[i].first
	end

# Flip Sort Order
#
# Causes the indicated column to be sorted in the opposite direction 
#
# Arguments:
#		name_or_index: (String|Integer) The column name or the index of the column to flip the sort direction (order)
#
#	Returns:
#		self
	def flip(name_or_index)
		i = name_or_index
		col_name = name_or_index
		# given string
		if name_or_index.is_a?(String)
			i = columns.index( name_or_index )
		# given int
		else
			col_name = ordering[i].first.first
		end
		h = ordering[i]
		if h[col_name].eql?(:desc)
			h[col_name] = :asc
		else
			h[col_name] = :desc
		end
		@ordering[i] = h
		self
	end

# Each
#
# Iterates over each ordering constraint.
#
# Block:
#		Arguments:
#			column_name: (String) the column to be sorted
#			direction: (Symbol) :asc for ascending sort, :desc for descending sort
#
	def each
		ordering.each do |r|
			yield r.first.first, r.first.last
		end
	end

# Collect
#
# Collects over each ordering constraint.
#
# Block:
#		Arguments:
#			column_name: (String) the column to be sorted
#			direction: (Symbol) :asc for ascending sort, :desc for descending sort
#
	def collect
		ordering.collect do |r|
			yield r.first.first, r.first.last
		end
	end

# Columns
#
# Gets an array of all column names. The order is preserved.
#
# Returns:
#		(Array) of column names
	def columns
		ordering.collect{|o| o.first.first}
	end

# Directions
#
# Gets an array of all directions. The order is preserved.
#
# Returns:
#		(Array) of direction symbols (:asc/:desc)
	def directions
		ordering.collect{|o| o.first.last}
	end

# Reverse
#
# Given an existing SortOrder, will reverse the columns and respective sort order. Therefore, if you have:
#
#	 > (CW::SortOrder.new + '1' - '2' - '3' - '4').reverse
# => #<CW::SortOrder:0x10033db68 @ordering=[{"4"=>:desc}, {"3"=>:desc}, {"2"=>:desc}, {"1"=>:asc}]>
#
# I'm not sure how this is useful. Whatever.
#
# Returns:
#		A copy of the caller, but with all columns and respective orderings reversed
	def reverse
		o = SortOrder.new
		ordering.reverse.each do |r|
			o.push( r.first.first, r.first.last )
		end
		o
	end

# Invert
#
# Given an existing SortOrder, will INVERT the columns and respective sort order. The columns do not move, but their orderings will be flipped Therefore, if you have:
#
#  > (CW::SortOrder.new + '1' - '2' - '3' - '4').invert
# => #<CW::SortOrder:0x10032f428 @ordering=[{"1"=>:desc}, {"2"=>:asc}, {"3"=>:asc}, {"4"=>:asc}]>
#
# Returns:
#		A copy of the caller, but with all column orderings inverted
	def invert
		o = self.dup
		0.upto(o.size - 1) do |i|
			o.flip(i)
		end
		o
	end

# Shift
#
# Pops the first order from the front and returns it as an array ['column_name',:asc|:desc]
#
# This was useful when creating the cw_pagination gem as it let me pull off the last element (of a reversed ordering) and manipulated it outside of a loop
#
#	Returns:
#		(Array) an ordered pair: [column_name,:asc|:desc]
	def shift
		t = @ordering.shift
		[t.keys.first,t.values.first] unless t.nil?
	end

# Select
#
#	Just like any Enumerable
#
#		Arguments:
#			column_name: (String) the column to be sorted
#			direction: (Symbol) :asc for ascending sort, :desc for descending sort
#
#	Returns:
#		(CW::SortOrder) but only containing the selected orderings
	def select
		o = SortOrder.new
		ordering.each do |r|
			c = r.first.first
			d = r.first.last
			o.push( c, d ) if yield( c, d )
		end
		o
	end

# Reject
#
#	Just like any Enumerable
#
#		Arguments:
#			column_name: (String) the column to be sorted
#			direction: (Symbol) :asc for ascending sort, :desc for descending sort
#
#	Returns:
#		(CW::SortOrder) but without the rejected orderings
	def reject
		o = SortOrder.new
		ordering.each do |r|
			c = r.first.first
			d = r.first.last
			o.push( c, d ) unless yield( c, d )
		end
		o
	end

# Concatenate
#
# Combines two CW::SortOrders to form a new one that is the union of the caller and the argument.
#
# Example:
#  > (CW::SortOrder.new + '1' - '2' - '3' - '4').concat( CW::SortOrder.new - '5' + '6' + '7' )
# => #<CW::SortOrder:0x10031a6e0 @ordering=[{"1"=>:asc}, {"2"=>:desc}, {"3"=>:desc}, {"4"=>:desc}, {"5"=>:desc}, {"6"=>:asc}, {"7"=>:asc}]>
#
# Returns:
#		A new CW::SortOrder, c such that for CW::SortOrders a and b,  c = a || b    OR   c = a.concat(b). This also lets you chain up sort orders
	def concat( o )
		raise ArgumentError.new( "Argument is not a CW::SortOrder" ) unless o.is_a?(CW::SortOrder)
		@ordering.concat(o.ordering)
		self
	end

# To String
#
# Converts a Sort Order to a SQL string
#
# Returns:
#		(String) version of the order as you would specify to a SQL query
	def to_s
		self.collect{|col,dir| "#{col} #{dir}"}.join(',')
	end

end # SortOrder
end # CW
