class SettingPositiveInteger < Setting

	validates_length_of :value, :allow_nil => true, :allow_blank => true, :maximum => 2048
	validates_length_of :previous_value, :allow_nil => true, :allow_blank => true, :maximum => 2048
	def self.friendly_type_description
<<EOD
An integer greater than, or equal to 0
EOD
	end
	validates_numericality_of :value, :allow_nil => true, :only_integer => true, :greater_than_or_equal_to => 0
	def value_typed
		self.read_attribute(:value).to_i unless self.read_attribute(:value).nil?
	end
end
