class EpisodePartAdInsertionPostRoll < EpisodePartAdInsertionLocation
	def self.friendly_type_description
<<EODOD
<p>These are ad slot reservations that appear after the video stops playing.</p>
EODOD
	end
	def location_in_content_in_words
		if self.episode_part and self.episode_part.video_content_name
			"end (#{self.episode_part.video_content_name.video_contents.inject(0.0){|initial,vc| initial + vc.length_in_seconds}}s)"
		else
			"end (?s)"
		end
	end

end
