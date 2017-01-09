class EpisodePart < ActiveRecord::Base
	include CW::ActsAs::Ordered::Model
	def self.acts_as_ordered_exclusivity_attribute_name; :episode_id; end
	belongs_to :episode
# do NOT delete video content automatically
	belongs_to :video_content_name

	has_many :episode_part_ad_insertion_locations, :dependent => :destroy

	validates_presence_of :episode_id
	validates_numericality_of :episode_id, :only_integer => true
	validates_length_of :name, :allow_nil => true, :in => 1..512

	validates_numericality_of :play_count, :only_integer => true

	def validate
		begin
			VideoContentName.find( self.video_content_name_id )
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :video_content_name_id, 'does not exist' )
		end
	end

	def record_play_count
		self.class.increment_counter( :play_count, self.id )
	end

	def will_be_available_in_future?( t = Time.now.utc )
		self.episode.will_be_available_in_future?( t )
	end

end
