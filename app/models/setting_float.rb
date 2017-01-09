class SettingFloat < Setting

	validates_length_of :value, :allow_nil => true, :allow_blank => true, :maximum => 2048
	validates_length_of :previous_value, :allow_nil => true, :allow_blank => true, :maximum => 2048
	def self.friendly_type_description
<<EOD
An floating point decimal (may contain fractions of a number). i.e. 1.5
EOD
	end
	validates_numericality_of :value, :allow_nil => true
	def value_typed
		self.read_attribute(:value).to_f unless self.read_attribute(:value).nil?
	end
end
