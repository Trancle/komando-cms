class UserInputBlacklist < ActiveRecord::Base
	include CW::ActsAs::Blacklistable::Blacklist
	validates_length_of :comment, :allow_empty => true, :allow_nil => true, :maximum => 4000

	VALID_SUBCLASSES = %w(UserInputBlacklistExact UserInputBlacklistRegularExpression).freeze
	def self.valid_subclass?( t )
		VALID_SUBCLASSES.include?( t )
	end

	def friendly_type_name
		self.class.name.sub('UserInputBlacklist','').underscore.humanize
	end

end
