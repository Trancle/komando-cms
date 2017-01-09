class EpisodePartAdInsertionLocation < ActiveRecord::Base
	belongs_to :episode_part

	validates_presence_of :episode_part_id
	validates_numericality_of :episode_part_id, :allow_nil => true, :only_integer => true

	validates_numericality_of :offset_from_start, :allow_nil => true

	validates_presence_of :enabled

	def ad_dispositions
		AdDisposition.find_by_insertion( self )
	end

	def friendly_type_name
		self.class.name.sub( 'EpisodePartAdInsertion','' ).underscore.humanize
	end

	VALID_SUBCLASS_NAMES = %w(EpisodePartAdInsertionPreRoll EpisodePartAdInsertionPostRoll EpisodePartAdInsertionMidRoll).freeze

	def self.valid_subclass_name?( n )
		VALID_SUBCLASS_NAMES.include?(n)
	end

	def location_in_content_in_words
		raise NotImplementedError.new( 'Subclasses of the ad insertion location must provide a way to query location in plain english' ) 
	end

	# need one function here that determines what advertising will go where
	# though ads are associated with multitudes of parameters, this point is always where an ad will be placed and will likely be the best place to do a lookup
	# this function will require significate work... later. This is the meat and potatoes of ad selection
	# TODO
	def select_ad( t = Time.now.utc )
		opts = AdSpot.find_running_ad_options( self, self.episode_part, self.episode_part.episode, self.episode_part.episode.show, t )
		# select the campaign id
		opts[:select] += ', link_ad_campaign_with_ad_spots.ad_campaign_id AS ad_campaign_id'
		# limit to reduce overflow probability
		spots = AdSpot.find(:all, opts.merge( :limit => 500 ) )

		dispositions = AdDisposition.find_summary_dispositions_for_spots( spots, self, self.episode_part, self.episode_part.episode, self.episode_part.episode.show, t )
		dispositions_h = {}
		# collapse dispositions into hash that holds sum of dispositions
		dispositions.each do |d|
			unless dispositions_h.key?(d.id)
				dispositions_h[d.id] = d.weight
			else
				dispositions_h[d.id] += d.weight
			end
		end
		dispositions = dispositions_h

# Any missing are given weight of 1
		spots.each do |spot|
			unless dispositions.key?(spot.id)
				dispositions[spot.id] = 1.0
			else
				dispositions[spot.id] += 1.0
			end
		end

# remove any 0 or negative weights, these mean that the ad will never show here
		dispositions.delete_if {|k,v| v <= 0.0}

		weightsum = dispositions.inject(0.0) {|m,kv| m + kv[1]}

		pick = rand( weightsum ).floor
		unless spots.empty?
			c = 0.0
			i = -1
			until( c >= pick or i >= spots.length - 1 )
				i += 1
				c += dispositions[spots[i].id] || 0.0
			end
			spots[i]
		end
# TODO: Add place where ad impression is recorded
	end

	def self.find_order_options
		# modify the order to put post-rolls at the back, always, this is pretty hackety, but works!
		{ :order => find_order_sort_order.collect{|c,d| "#{c} #{d}"}.join(',') }
	end

	def self.find_order_sort_order
		CW::SortOrder.asc( "'episode_part_ad_insertion_locations.' || replace( type, 'EpisodePartAdInsertionPreRoll', 'AEpisodePartAdInsertionLocationPreRoll')").asc( 'episode_part_ad_insertion_locations.offset_from_start' ).asc( 'episode_part_ad_insertion_locations.id' )
	end

	def position
		self.class.count( :conditions => ['id < ? AND type = ? AND episode_part_id = ?', self.id, self.class.name,self.episode_part_id] ) + 1
	end

end
