# Browser Version
# Encapsulates the version number of products
# Designed to provide an easy way to compare version numbers
# that are of the format: #.#.#.#... with any number of numbers in between
class ComponentizedProductVersion
	attr_reader :raw_version
	# Only include numbers and separators
# param[in] browser See UserAgent for a list of valid Browser Symbols: UserAgent::BROWSERS
	def initialize( version_string )
		@raw_version = version_string
	end

	def components( sep = '.' )
		@raw_version.split( sep ).collect{|r| r.to_i}
	end

# self <=> v
# returns -1 if we're less than (older) and 1 if greater (newer)
	def <=>( v )
		c = self.components
		vc = v.components
		csz = c.size
		vcsz = vc.size
		max_len = ( ( csz > vcsz ) ? csz : vcsz )
		i = 0
		while i < max_len
			if i < csz and i < vcsz
				# both have i number of components, compare them
				# if not eql, do something to compare, otherwise, we're equal and we need to move to the next component
				unless c[i].eql?(vc[i])
					if c[i] < vc[i]
						return -1
					else
						return 1
					end
				end
			else
				# equal up to this point, ran out of piddies
				return true if csz.eql?(vcsz)
				# we're equal up to this point, whoever has more non-zero components will win
				if i < csz
					# left has more components, are they zero?
					# if not zero, then we win (greater)
					return 1 unless c[i].eql?(0)
				else
					# right has more components, are they zero?
					# if not zero, then we win (less)
					return -1 unless vc[i].eql?(0)
				end
			end
			i += 1
		end
		return 0
	end

	def newer?( v )
		( self <=> v ).eql?(1)
	end

	def older?( v )
		( self <=> v ).eql?(-1)
	end

	def major
		c = self.components
		if c.size > 0
			return c[0]
		else
			return nil
		end
	end

	def major?( v )
		m = self.major
		return false if m.nil?
		return m.eql?(v)
	end

	def minor
		c = self.components
		if c.size > 1
			return c[1]
		else
			return nil
		end
	end

	def minor?( v )
		m = self.minor
		return false if m.nil?
		return m.eql?(v)
	end

	def eql?( v )
		( self <=> v ).eql?(0)
	end

	def ==( v )
		self.eql?(v)
	end

	def to_s
		raw_version
	end

end
