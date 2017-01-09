# Copyright 2011 Christopher Wojno
module CW

# Conditions for SQL Queries
#
# This case has happened to me so frequently, I decided to write a function to perform this logic for me.
#
# Say you have an Active Record query you want to make. You normally want to find all the Widgets with customizations, but this time, you want to search for customizations that are pink:
#
# Widget.find(:all, :conditions => 'customized' )
# Widget.find(:all, :conditions => ['color = ?', 'pink'] )
#
# But you want to combine them:
# Widget.find(:all, :conditions => ['customized AND color = ?','pink'] )
#
# Looks simple if you're doing this all hard-coded style, but if you want more flexible models where you're using functions to generate your conditions and then chaining up conditions, as I often do, then you'll need something to combine or chain up those conditions
#
# Enter Condition. It handles the 3 big cases: You're merging into a set of missing conditions (no conditions or nil conditions), conditions specified only as a string, or conditions as an Array.
#
# Examples:
#	class User < ActiveRecord::Base
#		def self.conditions_for_puppies
#			'EXISTS( SELECT * FROM users_with_puppies WHERE users_with_puppies.user_id = users.id )'
#		end
#		def self.conditions_for_of_age
#			'users.age >= 21' # Assuming United States adulthood, we mature a little more slowly than some to great effects ;-)
#		end
# end
#
# And if you want to select all users over the age of 21 with puppies in your controller
#	def list_of_age_with_puppies
#		User.find(:all, :conditions => CW::Condition.and( User.conditions_for_puppies, User.conditions_for_of_age ) )
# end
#
# You can even chain up additional ones for more refinement. Assume you have a form that asks to filter by name. That field has a name "name_is_like".
#
#	def list_of_age_with_puppies_filter_name
#		User.find(:all, :conditions => CW::Condition.and( CW::Condition.and( User.conditions_for_puppies, User.conditions_for_of_age ), ['lower(users.name) LIKE ?',params[:name_is_like]] ) )
#	end
#
# OK, it's a little ugly. But it was only designed to chain up a few of them. If you need to chain them up, instantiate the class and it will handle this for you.
#
#	Cleaner use: An instantiated condition merger:
#
#	Instead of using strings and arrays, use the class:
#	class User < ActiveRecord::Base
#		def self.conditions_for_puppies
#			CW::Condition.new 'EXISTS( SELECT * FROM users_with_puppies WHERE users_with_puppies.user_id = users.id )'
#		end
#		def self.conditions_for_of_age
#			CW::Condition.new 'users.age >= 21' # Assuming United States adulthood, we mature a little more slowly than some to great effects ;-)
#		end
# end
#
# And if you want to select all users over the age of 21 with puppies in your controller
#	def list_of_age_with_puppies
#		User.find(:all, :conditions => User.conditions_for_puppies.and( User.conditions_for_of_age ).done )
# end
#
# Or, to filter:
#
#	def list_of_age_with_puppies_filter_name
#		User.find(:all, :conditions => User.conditions_for_puppies.and( User.conditions_for_of_age ).and( ['lower(users.name) LIKE ?',params[:name_is_like]] ).done )
#	end
#
# The done call doesn't really do anything special. It simply gets the nil, string, or array representation of the conditions so far.
#
# On Arel:
#		If you have arel, the use that. This was written for apps that don't use Arel. Though, I'm not sure if Arel lets you build up conditions separately...
class Condition

# Merge AND
#
# Merges two conditions with AND
#
# Arguments:
#		src: (nil,String,Array) representing a query to chain with with
#		with: (nil,String,Array) representing a query to append to src
#
#	Return:
#		(nil,String,Array): the conditions merged together with AND
	def self.and( src, with )
		join( src, with, 'AND' )
	end

# Merge OR
#
# Merges two conditions with OR
#
# Arguments:
#		src: (nil,String,Array) representing a query to chain with with
#		with: (nil,String,Array) representing a query to append to src
#
#	Return:
#		(nil,String,Array): the conditions merged together with OR
	def self.or( src, with )
		join( src, with, 'OR' )
	end

# Merge AND NOT
#
# Merges two conditions with AND NOT
#
# Arguments:
#		src: (nil,String,Array) representing a query to chain with with
#		with: (nil,String,Array) representing a query to append to src
#
#	Return:
#		(nil,String,Array): the conditions merged together with AND NOT
	def self.and_not( src, with )
		join( src, with, 'AND NOT' )
	end

# Merge OR NOT
#
# Merges two conditions with OR NOT
#
# Arguments:
#		src: (nil,String,Array) representing a query to chain with with
#		with: (nil,String,Array) representing a query to append to src
#
#	Return:
#		(nil,String,Array): the conditions merged together with OR NOT
	def self.or_not( src, with )
		join( src, with, 'OR NOT' )
	end

# Merge with arbitrary clause
#
# Merges two conditions given an arbitrary clause. It's realy the work horse of this class. All other merging methods use this
#
# Arguments:
#		src: (nil,String,Array) representing a query to chain with with
#		with: (nil,String,Array) representing a query to append to src
#		join_clause: (String) representing how to join src and with
#
#	Return:
#		(nil,String,Array): the conditions merged together with join_clause
	def self.join( src, with, join_clause )
		if src.nil?
			return with
		end
		if with.nil?
			return src
		end

		raise ArgumentError.new("src can be nil, or a String or an Array or CW::Condition. It cannot be a #{src.class.name}") unless src.is_a?(Array) or src.is_a?(String) or src.is_a?(CW::Condition)
		raise ArgumentError.new("with can be nil, or a String or an Array or CW::Condition. It cannot be a #{with.class.name}") unless with.is_a?(Array) or with.is_a?(String) or with.is_a?(CW::Condition)
		raise ArgumentError.new("join_clause must be a String, not an #{join_clause.class.name}") unless join_clause.is_a?(String)

		src = src.conditions if src.is_a?(CW::Condition)
		with = with.conditions if with.is_a?(CW::Condition)

		if src.is_a?(String)
			if src.strip.empty?
				# coerse to array for conformity
				if with.is_a?(String)
					return [with]
				else
					return with
				end
			end
			src = [src]
		end
		if with.is_a?(String)
			return src if with.strip.empty?
			with = [with]
		end

		src[0] = '(' + src[0] + ') ' + join_clause + ' (' + with[0] + ')'
		src.concat( with[1..-1] ) if with.size > 1
		src
	end

	attr_reader :conditions
	def initialize( conditions = nil )
		@conditions = conditions
	end

# Append AND
#
# Appends a condition or set of conditions with AND
#
# Arguments:
#		c: (nil,String,Array,CW::Condition) The conditions to append
	def and( c )
		@conditions = self.class.and( conditions, c )
		self
	end

# Append OR
#
# Appends a condition or set of conditions with OR
#
# Arguments:
#		c: (nil,String,Array,CW::Condition) The conditions to append
	def or( c )
		@conditions = self.class.or( conditions, c )
		self
	end

# Append AND NOT
#
# Appends a condition or set of conditions with AND NOT
#
# Arguments:
#		c: (nil,String,Array,CW::Condition) The conditions to append
	def and_not( c )
		@conditions = self.class.and_not( conditions, c )
		self
	end

# Append OR NOT
#
# Appends a condition or set of conditions with OR NOT
#
# Arguments:
#		c: (nil,String,Array,CW::Condition) The conditions to append
	def or_not( c )
		@conditions = self.class.or_not( conditions, c )
		self
	end

# Append custom join_clause
#
# Appends a condition or set of conditions with a join clause of your choosing
#
# Arguments:
#		c: (nil,String,Array,CW::Condition) The conditions to append
#		how: (String) If the other append functions don't have what you need, try this. This will insert how between your clauses that you want merged
	def join( c, how = 'AND' )
		@conditions = self.class.join( conditions, c, how )
		self
	end

	alias :done :conditions

end # Condition
end # CW
