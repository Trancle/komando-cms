# CwActsAsBlacklistable
module CW
module ActsAs
module Blacklistable

# The black list
module Blacklist
	def self.included(base)
		base.extend(ClassMethods)

		base.validates_presence_of :value
		base.validates_uniqueness_of :value, :allow_nil => true
		base.validates_length_of :value, :in => 1..512, :allow_nil => true
	end

	def matches?( v, case_sensitive = false )
		raise NotImplementedError.new( "Not implemented in this class, please use Single Table Inheritance and include CW::ActsAs::Blacklistable::BlacklistExact and CW::ActsAs::Blacklistable::BlacklistRegularExpression" )
	end

	def matches_any?( v, case_sensitive = false )
		raise NotImplementedError.new( "Not implemented in this class, please use Single Table Inheritance and include CW::ActsAs::Blacklistable::BlacklistExact and CW::ActsAs::Blacklistable::BlacklistRegularExpression" )
	end

	module ClassMethods
		# Tests value, v, against all rules in the blacklist
		def matches?( v, case_sensitive = false )
			# Exact matches are easy, but not regexp
			chunk = 100
			round = 0
			s = []
			until ( s = find(:all, :conditions => ['enabled = ?',true], :limit => chunk, :offset => chunk*round) ).empty?
				round += 1
				s.each do |rule|
					return true if rule.matches?(v,case_sensitive)
				end
			end
			false
		end

		def matches( v, case_sensitive = false )
			# v is an array of values: same as single values, but test all values in array and return set of matching values
			matching = [] # start out with none
			test_against = v.dup

			chunk = 100
			round = 0
			s = []
			# chunk it until we run out of stuff
			until ( s = find(:all, :conditions => ['enabled = ?',true], :limit => chunk, :offset => chunk*round) ).empty? or test_against.empty?
				round += 1
				s.each do |rule|
					matching.concat( rule.matches( test_against, case_sensitive ) )

					# stop testing this value: already proven, no need to retest
					test_against.delete_if { |x| matching.include?(x) }
					return matching if test_against.empty?
				end
			end
			matching

		end

	end # ClassMethods
end # Blacklist

module BlacklistExact
	def self.include(base)
		base.extends(ClassMethods)
	end

	def matches?(v, case_sensitive = false)
		# remove punctuation and numbers
		v = v.delete( "^a-zA-Z" )
		if case_sensitive
			v.eql?self.value
		else
			v.downcase.eql?self.value.downcase
		end
	end

	def matches_any?( v, case_sensitive = false )
		v = [v] unless v.is_a?(Array)
		!v.detect{|val| self.matches?(val,case_sensitive)}.nil?
	end

	def matches( v, case_sensitive = false )
		v = [v] unless v.is_a?(Array)
		v.select{|val| self.matches?(val, case_sensitive) }
	end

	module ClassMethods
	end # ClassMethods
end #BlacklistExact

module BlacklistRegularExpression
	def self.include(base)
		base.extends(ClassMethods)
	end

	def matches?( v, case_sensitive = false )
		opts = nil
		opts = Regexp::IGNORECASE unless case_sensitive
		r = Regexp.new( self.value, opts )
		!r.match(v).nil?
	end

	def matches_any?( v, case_sensitive = false )
		v = [v] unless v.is_a?(Array)
		!v.detect{|val| self.matches?(val, case_sensitive) }.nil?
	end

	def matches( v, case_sensitive = false )
		v = [v] unless v.is_a?(Array)
		v.select{|val| self.matches?(val, case_sensitive) }
	end

	module ClassMethods
	end # ClassMethods
end #BlacklistRegularExpression


module Blacklistable
	def self.included(base)
		base.extend(ClassMethods)
	end


	module ClassMethods
		def blacklistable_find_matches_against( blacklist_klass, hash_of_strings = {} )
			ret = {}
			stringset = nil
# break down each hash
			hash_of_strings.each_pair do |k,v|
				# parse the string into a list of words: eliminates punctuation
				stringset = v.split.collect{|e| e.strip}.uniq
				# remove empty string
				stringset.delete_if{|e| e.eql?''}
# for each word in the string, test against the blacklist
				m = blacklist_klass.matches( stringset )
				ret[k] = m unless m.empty?
			end
			ret # any words in the retuned value are restricted words
		end
	end # ClassMethods
end#Blacklistable


# Migration to create the blacklist
module Migration
	def self.included(base)
		base.extend(ClassMethods)
	end

	module ClassMethods
		def create_blacklist_table( table_name, &block )
			create_table( table_name ) do |t|
				t.column :type, :string, :null => false
				t.column :value, :string, :null => false
				t.column :enabled, :boolean, :null => false, :default => true
				t.timestamps
				yield(t) if block_given?
			end
			add_index table_name, [:type,:value], :unique => true
		end
	end #ClassMethods
end #Migration

end#Blacklistable
end#ActsAs
end#CW
