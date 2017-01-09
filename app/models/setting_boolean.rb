class SettingBoolean < Setting
	def self.friendly_type_description
<<EOD
A boolean. It's either yes (true) or no (false) (checked or not checked, respectively).
EOD
	end

	def value_typed
		self.read_attribute(:value).eql?'t' unless self.read_attribute(:value).nil?
	end

	def value=( v )
		unless v.is_a?(String)
			self.write_attribute(:value, ( v ? 't' : 'f' ) )
		else
			if v.eql?'t' or v.eql?'1'
				self.write_attribute(:value, 't' )
			else
				self.write_attribute(:value, 'f' )
			end
		end
	end

	def previous_value_typed
		self.read_attribute(:previous_value).eql?'t' unless self.read_attribute(:previous_value).nil?
	end

	def previous_value=( v )
		unless v.is_a?(String)
			self.write_attribute(:previous_value, ( v ? 't' : 'f' ) )
		else
			if v.eql?'t' or v.eql?'1'
				self.write_attribute(:previous_value, 't' )
			else
				self.write_attribute(:previous_value, 'f' )
			end
		end
	end
end
