class CwAuthorizationManager < ActiveRecord::Base
	def self.authorization_mechanism; CwAuthorizationManagerConfig.authorization_mechanism.constantize; end
end
