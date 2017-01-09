class EpisodePartAdInsertionMidRoll < EpisodePartAdInsertionLocation

	validates_presence_of :offset_from_start
	validates_numericality_of :offset_from_start

	def self.friendly_type_description
<<EODOD
<p>These are ad slot reservations that appear within a video. Video will stop playback at the indicated time and play an advertisement, then resume the episode part.</p>
EODOD
	end
	def location_in_content_in_words
		"+#{self.offset_from_start}s"
	end
	def position
		self.class.count( :conditions => ['id < ? AND type = ? AND episode_part_id = ? AND offset_from_start = ?', self.id, self.class.name,self.episode_part_id, self.offset_from_start] ) + 1
	end
end
