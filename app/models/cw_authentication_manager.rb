class CwAuthenticationManager < ActiveRecord::Base
	def self.authentication_mechanism; CwAuthenticationManagerConfig.authentication_mechanism.constantize; end
end
