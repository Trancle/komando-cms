class SettingString < Setting

	def value_typed
		self.value
	end

	validates_length_of :value, :allow_nil => true, :allow_blank => true, :maximum => 2048
	validates_length_of :previous_value, :allow_nil => true, :allow_blank => true, :maximum => 2048
	def self.friendly_type_description
<<EOD
A string. Arbitrary text without formatting constraints.
EOD
	end
end
