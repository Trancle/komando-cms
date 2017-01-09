module CW
module MuExDateRange
module RangeWithNilForm

	def self.included(base)
		base.before_validation :enforce_nil_start_end
	end

	def start_at_is_nil=( v )
		@start_at_is_nil = true
	end
	def end_at_is_nil=( v )
		@end_at_is_nil = true
	end

	def enforce_nil_start_end
		self.start_at = nil if @start_at_is_nil
		self.end_at = nil if @end_at_is_nil
		@start_at_is_nil = false
		@end_at_is_nil = false
# must do this otherwise validation will 'fail'
		return true
	end

end#RangeWithNilForm
end#MuExDateRange
end#CW
