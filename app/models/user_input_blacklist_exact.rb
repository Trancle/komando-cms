class UserInputBlacklistExact < UserInputBlacklist
	include CW::ActsAs::Blacklistable::BlacklistExact

	def self.friendly_type_description
<<EOD
Matches a word exactly, minus any punctuation and numbers. So: "badword" must be exactly equal to "badword". "bad word" will not match; however, "bad-word" will. "badword2" will match as well.
EOD
	end

	DEFAULT_DEADLY_WORDS = %w(cunts cunt kunt kunts piss shit shits shitting shitter tits tit twat twats ass asses milf cocksucker cocksuckers pissed pissedoff jerkoff jerkoffs cum cumming blowjob blowjobs boner boners bullshit bullshits clit clits beaner beaners chinc chincs pussy pussies slut sluts slutty wetback wetbacks whore whores jerk bitch bitches bastard bastards skank skanks wank wanker wanks wankers)

	def self.add_default_deadly_words
		DEFAULT_DEADLY_WORDS.each do |w|
			new( :value => w, :comment => 'part of the default deadly words' ).save
		end
	end
end
