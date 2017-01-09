# CwMuExDateRange
module CW
# Include this into your active record model that will represent your date range
module MuExDateRange

# Sets contain multiple ranges. They are the baseline to which the mutual exclusivity is set
# When lookin up ranges, they're only sensical within a set context
module Set
	attr_reader :exclusivity_id


	def self.included(base)
		base.extend(ClassMethods)
	end



	def new_range
		r = self.class.cw_mu_ex_date_range_range_klass.new()
		# exclusivity ID is protected from mass-assignment
		r.exclusivity_id = @exclusivity_id
		r
	end


	def all
		self.class.cw_mu_ex_date_range_range_klass.find(:all, :conditions => ['exclusivity_id = ?',@exclusivity_id], :order => 'start_at, end_at' )
	end




	def find_range_including( d )
		self.class.cw_mu_ex_date_range_range_klass.find(:first,:conditions => self.class.conditions_for_range_including( self.class.cw_mu_ex_date_range_range_klass.table_name, @exclusivity_id, d ), :limit => 1 )
	end

	def includes?( d )
		!self.find_range_including( d ).nil?
	end

	def overlapped( date_range )
		date_range.exclusivity_id = @exclusivity_id
		date_range.overlaps
	end


	def initialize( exid = nil )
		raise ArgumentError.new( "Sets require an exclusivity ID. It won't generate one for you. You should link it up to some other model." ) if exid.nil?
		@exclusivity_id = exid
	end

	module ClassMethods
#		def cw_mu_ex_date_range_range_klass
#raise NotImplementedError.new( "You must overwrite: cw_mu_ex_date_range_range_klass class function to specify the class of the CW::MuExDateRange::Range ActiveRecord::Base model class" )
#		end

		def find_by_exclusivity_id( theid )
			if cw_mu_ex_date_range_range_klass.count(:conditions => ['exclusivity_id = ?',theid], :readonly => true ).eql?0
				nil
			else
				new( theid )
			end
    end

=begin
Find the set of ranges that are in the given exclusivity ids, that include the given value. This is designed to
allow broad searches across several exclusivity IDs to help consolidate queries
=end
    def find_ranges_with_exclusivity_ids_including( xtable_name, exclusivity_ids, t )
      tn = xtable_name + '.'
      conds = ['']
      unless exclusivity_ids.nil?
        conds[0] += "#{tn}exclusivity_id IN ("
        if exclusivity_ids.is_a?(Array)
          conds[0] += exclusivity_ids.collect{|e|'?'}.join(',')
          conds.concat( exclusivity_ids )
        else
          conds[0] += '?'
          conds << exclusivity_ids
        end
        conds[0] += ") AND "
      end
      conds[0] += "( ( #{tn}start_at IS NULL AND #{tn}end_at IS NULL ) OR ( #{tn}start_at IS NULL AND ? < #{tn}end_at ) OR ( #{tn}end_at IS NULL AND #{tn}start_at <= ? ) OR ( #{tn}start_at <= ? AND ? < #{tn}end_at ) )"
      conds.concat( [t,t,t,t] )
      conds

    end

		def conditions_for_range_including( xtable_name, exclusivity_id, t )
      find_ranges_with_exclusivity_ids_including( xtable_name, exclusivity_id, t )
		end

		def find_next_range( exclusivity_id, t )
			self.cw_mu_ex_date_range_range_klass.find( :first, find_next_range_find_options( self.cw_mu_ex_date_range_range_klass.table_name, exclusivity_id, t ) )
		end

		def find_next_range_find_options( xtable_name, exclusivity_id, t )
			tn = xtable_name + '.'
			{ :conditions => ["#{tn}exclusivity_id = ? AND ( #{tn}start_at > ? )",exclusivity_id,t], :limit => 1, :order => "#{tn}start_at ASC" }
		end

		def find_previous_range_find_options( xtable_name, exclusivity_id, t )
			tn = xtable_name + '.'
			{ :conditons => ["#{tn}exclusivity_id = ? AND ( #{tn}end_at <= t )",exclusivity_id,t], :limit => 1, :order => "#{tn}end_at DESC" }
		end

		def find_previous_range( exclusivity_id, t )
			self.cw_mu_ex_date_range_range_klass.find( :first, find_previous_range_find_options( self.cw_mu_ex_date_range_range_klass.table_name, exclusivity_id, t ) )
		end
	end# ClassMethods

end#Set


# Ranges: Start_at is always inclusive, end_at is always exclusive: [start_at,end_at)
module Range

	CW_MU_DATE_RANGE_TYPES = [:open,:open_begin,:open_end,:closed].freeze

	def validate
		if start_at and end_at
			errors.add( :start_at, "must always the same as or earlier than the end date" ) if start_at > end_at
		end
		begin
			errors.add_to_base( "This range will overlap with an existing range. This is not permitted." ) if will_overlap?
		rescue InvertedDateOrderError => s
			# this will be caught above, but for now: prevent raising this too far
		end
	end

	def self.included(base)
		base.extend(ClassMethods)
		base.attr_protected :exclusivity_id if base.respond_to?(:attr_protected)
		base.before_save :will_not_overlap?
	end

	def range_type
		return :open if end_at.nil? and start_at.nil?
		return :open_end if end_at.nil? and !start_at.nil?
		return :open_begin if start_at.nil? and !end_at.nil?
		return :closed
	end

	def will_not_overlap?
		!self.will_overlap?
	end

	def will_overlap?
		options = self.class.find_all_in_range_options( self.class.table_name, self.exclusivity_id, self.start_at, self.end_at, self.id )
		!self.class.count( options ).eql?0
	end

	def overlaps
		options = self.class.find_all_in_range_options( self.class.table_name, self.exclusivity_id, self.start_at, self.end_at, self.id )
		options[:order] = 'start_at'
		self.class.find( :all, options )
	end


	def -( r )
		ret = { :delete => nil, :update => nil, :split => nil }
		res = self.class.range_subtract( self.start_at, self.end_at, r.start_at, r.end_at )
		case res.size
			when 0
				ret[:delete] = self # delete the range
			when 2
				# resize the range
				t = self.dup
				t.start_at = res[0]
				t.end_at = res[1]
				ret[:update] = t
			when 4
				# split the range
				t = self.dup
				n = self.class.new( self.attributes )
				n.exclusivity_id = self.exclusivity_id
				t.start_at = res[0]
				t.end_at = res[1]
				n.start_at = res[2]
				n.end_at = res[3]
				ret[:split] = { :old => t, :new => n }
		end
		ret
	end

	def includes?( t = Time.now.utc )
		if self.start_at.nil? and self.end_at.nil?
			true
		elsif self.start_at.nil? and !self.end_at.nil?
			t < self.end_at
		elsif !self.start_at.nil? and self.end_at.nil?
			t >= self.start_at
		else
			self.start_at <= t and t < self.end_at
		end
	end

	module ClassMethods

		def find_first_containing( exclusivity_id, t = Time.now.utc )
			self.find( :first, self.find_first_containing_options( self.table_name, exclusivity_id, t ) )
		end

		def find_first_containing_options( xtable_name, exclusivity_id, t = Time.now.utc )
			find_all_in_range_options( xtable_name, exclusivity_id, t, t )
		end

		def find_all_in_range_options( xtable_name, exclusivity_id = nil, s = nil, e = nil, theid = nil )
			raise InvertedDateOrderError.new("start is not less than or equal to end") unless range_pair_valid?(s,e)
			tn = xtable_name + '.'
			conds = ['']
			if !exclusivity_id.nil? or !theid.nil?
				conds[0] += '('
				unless exclusivity_id.nil?
					conds[0] += "#{tn}exclusivity_id = ? "
					conds << exclusivity_id
				end
				# exclude ourselves, if necessary:
				unless theid.nil?
					conds[0] += " AND #{tn}id <> ?"
					conds << theid
				end
				conds[0] += ') AND '
			end
			conds[0] += "( ( #{tn}start_at IS NULL AND #{tn}end_at IS NULL )"
			if s.nil? and e.nil?
				# nothing to do, search all time, holds true if there are other times with no start & end
				conds[0] += ' OR ( 1 = 1 )'
			elsif !s.nil? and e.nil?
				# start is definite, end is not definite
				conds[0] += " OR ( ( #{tn}end_at > ? ) OR ( #{tn}end_at IS NULL ) )"
				conds << s
			elsif s.nil? and !e.nil?
				# end is definite, start is not definite
				conds[0] += " OR ( ( #{tn}start_at < ? ) OR ( #{tn}start_at IS NULL ) )"
				conds << e
			else
				# both start and end are specified
			  # logic check:
				# test line is 1,4
			  # 1:  3,INF
			  # 2: -INF,2
			  # 3:  5,INF
			  # 4: -INF,0
			  # 5:  2,3
			  # 6: -INF,INF
			  # 7: -INF,5
			  # 8:  0,INF
				conds[0] += " OR ( ( ( #{tn}start_at < ? OR #{tn}start_at IS NULL ) AND ( ? < #{tn}end_at OR #{tn}end_at IS NULL ) ) OR ( #{tn}start_at < ? AND #{tn}start_at >= ? ) OR ( #{tn}end_at > ? AND #{tn}end_at < ? ) )"
				conds << e
				conds << s
				conds << e
				conds << s
				conds << s
				conds << e
			end
			conds[0] += ')'
			{ :conditions => conds }
		end


		def range_pair_valid?( x, y )
			if x.nil? or y.nil?
				return true
			else
				return x <= y
			end
		end

		def range_array_to_individual_variables( s1, e1, s2, e2 )
			if s1.is_a?(Array)
				e2 = s1[3]
				s2 = s1[2]
				e1 = s1[1]
				s1 = s1[0]
			end
			return s1, e1, s2, e2
		end

		def range_subtract( s1, e1 = nil, s2 = nil, e2 = nil )
			s1, e1, s2, e2 = range_array_to_individual_variables( s1, e1, s2, e2 )
			raise InvertedDateOrderError.new("start(1) is not less than or equal to end(1)") unless range_pair_valid?(s1,e1)
			raise InvertedDateOrderError.new("start(2) is not less than or equal to end(2)") unless range_pair_valid?(s2,e2)

			# now we know they overlap: there's something to slice up. there will always be at most 2 parts, at least 0 parts

			if s1.nil? and e1.nil? and s2.nil? and e2.nil?		# 0000
				[]
			elsif s1.nil? and e1.nil? and s2.nil? and e2			# 0001
				[e2,nil]
			elsif s1.nil? and e1.nil? and s2 and e2.nil?			# 0010
				[nil,s2]
			elsif s1.nil? and e1.nil? and s2 and e2						# 0011
				[nil,s2,e2,nil]
			elsif s1.nil? and e1 and s2.nil? and e2.nil?			# 0100
				[]
			elsif s1.nil? and e1 and s2.nil? and e2						# 0101
				if e1 <= e2
					[]
				else
					[e2,e1]
				end
			elsif s1.nil? and e1 and s2 and e2.nil?						# 0110
				if e1 <= s2
					[nil,e1]
				else
					[s2,e1]
				end
			elsif s1.nil? and e1 and s2 and e2								# 0111
				if e1 <= s2 and e1 <= e2
					[nil,e1]
				elsif s2 < e1 and e2 < e1
					[nil,s2,e2,e1]
				elsif s2 < e1 and e2.eql?e1
					[nil,s2]
				elsif e1.eql?s2
					[nil,e1]
				else
					[nil,s2]
				end
			elsif s1 and e1.nil? and s2.nil? and e2.nil?			# 1000
				[]
			elsif s1 and e1.nil? and s2.nil? and e2						# 1001
				if s1 < e2
					[e2,nil]
				else
					[s1,nil]
				end
			elsif s1 and e1.nil? and s2 and e2.nil?						# 1010
				if s1 >= s2
					[]
				else
					[s1,s2]
				end
			elsif s1 and e1.nil? and s2 and e2								# 1011
				if s1 < s2
					[s1,s2,e2,nil]
				else
					if s1 >= e2
						[s1,nil]
					else
						[e2,nil]
					end
				end
			elsif s1 and e1 and s2.nil? and e2.nil?						# 1100
				[]
			elsif s1 and e1 and s2.nil? and e2								# 1101
				if s1 < e2
					if e1 <= e2
						[]
					else
						[e2,e1]
					end
				else
					[s1,e1]
				end
			elsif s1 and e1 and s2 and e2.nil?								# 1110
				if e1 > s2
					if s1 >= s2
						[]
					else
						[s1,s2]
					end
				else
					[s1,e1]
				end
			elsif s1 and e1 and s2 and e2											# 1111
				if s2 <= s1 and e1 <= e2
					# inside or equal: either way, all gets erased
					[]
				else
					# not inside and not equal
					if e2 <= s1 or s2 >= e1
						[s1,e1]
					else
						# cut is within
						if s1 < s2 and e2 < e1
							[s1,s2,e2,e1]
						else
							if e2 < e1
								[e2,e1]
							else
								[s1,s2]
							end
						end
					end
				end
			end
			
		end

		# exhaustive test to see if 2 ranges overlap: All 16 combinations of nils
		def ranges_overlap?( s1, e1 = nil, s2 = nil, e2 = nil )
			s1, e1, s2, e2 = range_array_to_individual_variables( s1, e1, s2, e2 )
			raise InvertedDateOrderError.new("start(1) is not less than or equal to end(1)") unless range_pair_valid?(s1,e1)
			raise InvertedDateOrderError.new("start(2) is not less than or equal to end(2)") unless range_pair_valid?(s2,e2)
			if s1.nil? and e1.nil? and s2.nil? and e2.nil?		# 0000
				true
			elsif s1.nil? and e1.nil? and s2.nil? and e2			# 0001
				true
			elsif s1.nil? and e1.nil? and s2 and e2.nil?			# 0010
				true
			elsif s1.nil? and e1.nil? and s2 and e2						# 0011
				true
			elsif s1.nil? and e1 and s2.nil? and e2.nil?			# 0100
				true
			elsif s1.nil? and e1 and s2.nil? and e2						# 0101
				true
			elsif s1.nil? and e1 and s2 and e2.nil?						# 0110
				# maybe
				s2 < e1
			elsif s1.nil? and e1 and s2 and e2								# 0111
				# maybe
				s2 < e1
			elsif s1 and e1.nil? and s2.nil? and e2.nil?			# 1000
				true
			elsif s1 and e1.nil? and s2.nil? and e2						# 1001
				#maybe
				s1 < e2
			elsif s1 and e1.nil? and s2 and e2.nil?						# 1010
				true
			elsif s1 and e1.nil? and s2 and e2								# 1011
				#maybe
				e2 > s1
			elsif s1 and e1 and s2.nil? and e2.nil?						# 1100
				true
			elsif s1 and e1 and s2.nil? and e2								# 1101
				# maybe
				s1 < e2
			elsif s1 and e1 and s2 and e2.nil?								# 1110
				# maybe
				s2 < e1
			elsif s1 and e1 and s2 and e2											# 1111
				( ( s1 <= s2 ) and ( s2 < e1 ) ) or ( ( s2 <= s1 ) and ( s1 < e2 ) )	
			end
		end

		# true if range 1 is completely within range 2, false if otherwise
		def range_completely_within_range?( s1, e1 = nil, s2 = nil, e2 = nil )
			s1, e1, s2, e2 = range_array_to_individual_variables( s1, e1, s2, e2 )
			raise InvertedDateOrderError.new("start(1) is not less than or equal to end(1)") unless range_pair_valid?(s1,e1)
			raise InvertedDateOrderError.new("start(2) is not less than or equal to end(2)") unless range_pair_valid?(s2,e2)
			if s1.nil? and e1.nil? and s2.nil? and e2.nil?		# 0000
				true
			elsif s1.nil? and e1.nil? and s2.nil? and e2			# 0001
				false
			elsif s1.nil? and e1.nil? and s2 and e2.nil?			# 0010
				false
			elsif s1.nil? and e1.nil? and s2 and e2						# 0011
				false
			elsif s1.nil? and e1 and s2.nil? and e2.nil?			# 0100
				true
			elsif s1.nil? and e1 and s2.nil? and e2						# 0101
				s1 <= s2
			elsif s1.nil? and e1 and s2 and e2.nil?						# 0110
				false # (-inf,x),(y,inf)
			elsif s1.nil? and e1 and s2 and e2								# 0111
				false
			elsif s1 and e1.nil? and s2.nil? and e2.nil?			# 1000
				true
			elsif s1 and e1.nil? and s2.nil? and e2						# 1001
				false # (x,inf),(-inf,y), will never be completley within
			elsif s1 and e1.nil? and s2 and e2.nil?						# 1010
				s2 <= s1
			elsif s1 and e1.nil? and s2 and e2								# 1011
				false
			elsif s1 and e1 and s2.nil? and e2.nil?						# 1100
				true
			elsif s1 and e1 and s2.nil? and e2								# 1101
				e1 <= e2
			elsif s1 and e1 and s2 and e2.nil?								# 1110
				s2 <= s1
			elsif s1 and e1 and s2 and e2											# 1111
				s2 <= s1 and e1 <= e2
			end
		end
	end#ClassMethods

	class InvertedDateOrderError < StandardError
	end

end#Range

module Migration
	def self.included(base)
		base.extend(ClassMethods)
	end

	module ClassMethods
		def create_date_range_table( tablename, exclusivity_id_type = :integer, &block )
			create_table(tablename) do |t|
				t.column :start_at, :datetime, :null => true
				t.column :end_at, :datetime, :null => true
				t.column :exclusivity_id, exclusivity_id_type, :null => false

				# allows user to set own info
				yield(t) if block_given?
			end
			# we'll do LOTS of searching by exclusivity_id
			add_index tablename, :exclusivity_id
		end #ClassMethods


	end
end # Migration
end #MuExDateRange
end #CW
