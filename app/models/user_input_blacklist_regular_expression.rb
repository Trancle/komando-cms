class UserInputBlacklistRegularExpression < UserInputBlacklist
	include CW::ActsAs::Blacklistable::BlacklistRegularExpression

	def self.friendly_type_description
<<EOD
Matches a word using regular expressions, ruby style.
EOD
	end

	def self.add_default_prevent_comment_links
		new( :value => '://', :comment => 'Prevents inserting links into comments by denying \'://\' from appearing anywhere in the message' ).save
		new( :value => 'fuck', :comment => 'Matches' ).save
		new( :value => 'nigger', :comment => 'Matches' ).save
	end
end
