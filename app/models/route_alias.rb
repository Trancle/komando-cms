require 'set'
class RouteAlias < ActiveRecord::Base
	include CW::MuExDateRange::Range

	validates_presence_of :alias_to
	validates_presence_of :exclusivity_id

	validates_length_of :alias_to, :allow_nil => true, :allow_blank => false, :in => 1..2048
	validates_length_of :exclusivity_id, :allow_nil => true, :allow_blank => false, :in => 1..2048

	def destination; self.exclusivity_id; end

	def validate
		if self.alias_to.eql?self.exclusivity_id
			self.errors.add( :exclusivity_id, 'creates a cycle (and these are not permitted); do not create aliases that point to themselves' )
		end
		if in_cycle? and self.enabled
			self.errors.add( :exclusivity_id, 'creates a cycle (and these are not permitted)' )
		end
	end

	# this could be a VERY slow process; uses vertex coloring
	def in_cycle?
		return true if self.alias_to.eql?self.exclusivity_id
		tocheck = self.aliases_to_me
		rounds = 0
		seenids = Set.new
		seenids.add self.id if self.id
		until tocheck.empty?
			checking = tocheck.shift
			if seenids.include?( checking.id ) or ( checking.exclusivity_id.eql?self.alias_to )
				# we've seen this ID before
				return true
			else
				# no cycle, see who points to this one and add them to the check list
				tocheck.concat( checking.aliases_to_me )
			end
			seenids.add checking.id
		end
		# no cycle
		return false
	end

	def aliases_to_me
		opts = self.class.find_all_in_range_options( self.class.table_name, nil, self.start_at, self.end_at, self.id )
		opts[:conditions][0] += " AND ( enabled = ? AND alias_to = ? )"
		opts[:conditions] << true
		opts[:conditions] << self.exclusivity_id
		self.class.find( :all, opts )
	end


end
