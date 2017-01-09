class LinkEpisodeWithEpisodeTag < ActiveRecord::Base
	def self.taggable_klass; 'Episode'.constantize; end
	include CW::ActsAs::Taggable::Link

	validates_presence_of :tag_id
	validates_presence_of :taggable_id

	def validate
		begin
			EpisodeTag.find( self.tag_id )
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :tag_id, "does not exist" )
		end
		begin
			Episode.find( self.taggable_id )
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :tag_id, "does not exist" )
		end
	end
end
