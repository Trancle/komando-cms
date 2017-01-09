# CwStandAloneTimeHelper
module CW
class StandAloneTimeHelper

	attr_reader :t

	def initialize( attrs = {} )
		@z = attrs[:z] || 'utc'
		@t = attrs[:t] || Time.send( @z, (attrs['t(1i)'] || 0).to_i, (attrs['t(2i)']||0).to_i, (attrs['t(3i)']||0).to_i, (attrs['t(4i)']||0).to_i, (attrs['t(5i)']||0).to_i, (attrs['t(6i)']||0).to_i, (attrs['t(1i)'] ||0).to_i )
	end


end#StandAloneTimeHelper
end#CW
