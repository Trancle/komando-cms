class SettingDate < Setting

	validates_length_of :value, :allow_nil => true, :allow_blank => true, :maximum => 2048
	validates_length_of :previous_value, :allow_nil => true, :allow_blank => true, :maximum => 2048
	def self.friendly_type_description
<<EOD
A datetime. Datetimes have the following formats: 'http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3'.
EOD
	end

	def value_typed
		DateTime.parse( self.read_attribute(:value) ) unless self.read_attribute(:value).nil?
	end

	def value=( v )
		begin
			self.write_attribute(:value,Time.parse(v).to_s)
		rescue ArgumentError => e
			self.errors.add( :value, 'is not a valid date' )
		end
	end
end
