class EpisodePartAdInsertionPreRoll < EpisodePartAdInsertionLocation
	def self.friendly_type_description
<<EODOD
<p>These are ad slot reservations that appear before a video starts playing.</p>
EODOD
	end
	def location_in_content_in_words
		'start (0.0s)'
	end
end
