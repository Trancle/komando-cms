require File.dirname(__FILE__) + '/../modules/add_xml_json_to_taggables.rb'
require File.dirname(__FILE__) + '/../modules/ws_taggable.rb'
class Show < ActiveRecord::Base
	include CW::ActsAs::Versioned::Stub
	def self.scheduled_version_cw_mu_ex_date_range_set_klass; "ShowVersionScheduleDateSet".constantize; end
	def self.scheduled_version_cw_mu_ex_date_range_range_klass; "ShowVersionScheduleDate".constantize; end
	def self.scheduled_version_klass; "ShowVersionSchedule".constantize; end
	def self.versioned_model_klass; "ShowVersion".constantize; end
	include CW::ScheduledVersion::Stub
	def self.category_base_klass; "ShowCategory".constantize; end
  def self.taggable_base_klass; "ShowTag".constantize; end
	def self.category_link_klass; "LinkShowWithShowCategory".constantize; end
	include CW::ActsAs::Categorized::Categorizeable

	include CW::ActsAs::Ordered::Model

	include CW::ActsAs::Cacheable
  include WS::Taggable

	# clean up episodes on deletion too!
	has_many :episodes, :dependent => :destroy
	has_many :show_versions, :foreign_key => :version_stub_id, :dependent => :destroy

	# kill any related links associated with this show, need a way to do the same for any shows related to this one
	has_many :link_show_to_related_shows, :dependent => :destroy
	has_many :related_shows, :through => :link_show_to_related_shows, :class_name => self.name

	has_many :show_publish_dates, :foreign_key => :exclusivity_id, :dependent => :destroy

  has_many :taggings, :class_name => 'ShowTagging', :include => 'tag', :dependent => :destroy
  has_many :tags, :class_name => 'ShowTag', :through => :taggings, :source => 'tag'




	validates_length_of :keywords, :allow_nil => true, :allow_blank => true, :maximum => 1024
	validates_numericality_of :episodes_per_page, :only_integer => true, :greater_than_or_equal_to => 1
	attr_protected :ts_index

  validates_presence_of :number_watch_page_episodes
  validates_numericality_of :number_watch_page_episodes, :only_integer => true, :greater_than_or_equal_to => 1

# destroys related show links on show deletion
	def before_destroy
		LinkShowToRelatedShow.destroy_all( ['related_show_id = ?', self.id] )
	end


	def scheduled_version_current_or_last_version
		scheduled_version_current_cache || self.version( :last )
	end
	
	acts_as_cacheable_cache_method( :scheduled_version_current )
	acts_as_cacheable_cache_method( :scheduled_version_current_or_last_version )
	acts_as_cacheable_cache_method( :version_count )

	def available?( t = Time.now.utc )
		self.published and !self.scheduled_version_current_cache.nil? and ShowPublishDateSet.new( self.id ).includes?(t)
	end

	def will_be_available_in_future?( t = Time.now.utc )
		test = ShowPublishDate.new( :start_at => t, :end_at => nil )
		test.exclusivity_id = self.id
		test.will_overlap?
	end

	def self.find_available_show_options( opts = {}, t = Time.now.utc )
		o = Show.scheduled_version_find_current_stubs_options( t )

		# view only published shows
		o[:conditions][0] += ' AND shows.published = ?'
		o[:conditions] << true
		
		# Only shows that are current
		c = ShowPublishDateSet.conditions_for_range_including( 'show_publish_dates', nil, t )
		o[:conditions][0] += " AND EXISTS ( SELECT * FROM show_publish_dates WHERE #{c[0]} AND show_publish_dates.exclusivity_id = shows.id )"
		o[:conditions].concat( c[1..-1] )

		# Enforce manual ordering
		o.merge( Show.order_options )

		# Allow user to futher customize
		o.merge( opts )
	end

# converts a string into a friendly english URL
	def self.urlize( t )
		# make ' as though it's not there, everything else is converted to a single -
		t = t.strip.downcase.gsub('\'','').gsub( /[^a-z0-9]/, '-' ).squeeze('-')
		t = t[0..-2] if t.last.eql?'-'
		t = t[1..-1] if t.first.eql?'-'
		return t
	end

	def self.find_available_show_by_url_title_options( title, opts = {}, t = Time.now.utc )
		c = Show.find_available_show_options( opts, t )
		# now, add the show title restriction
		c[:joins] += ' INNER JOIN show_versions ON show_versions.id = show_version_schedules.version_id'
		c[:conditions][0] += ' AND show_versions.url_title LIKE ?'
		c[:conditions] << "%#{title}%" 
		c
	end

	def self.find_related_active_shows_options( show_id, t = Time.now.utc )
		opts = find_available_show_options( {}, t )

		opts[:joins] += ActiveRecord::Base.sanitize_sql_array( [' INNER JOIN link_show_to_related_shows ON link_show_to_related_shows.show_id = ? AND link_show_to_related_shows.related_show_id = shows.id',show_id] )

		opts
	end

	def find_related_active_shows( t = Time.now.utc )
		self.class.find( :all, self.class.find_related_active_shows_options( self.id, t ) )
	end
	def count_related_active_shows( t = Time.now.utc )
		self.class.count( self.class.find_related_active_shows_options( self.id, t ) )
	end

	def are_episode_comments_enabled?( t = Time.now.utc )
		self.episode_comments_enabled
	end

	def is_episode_user_tagging_enabled?( t = Time.now.utc )
		self.episode_user_tagging_enabled
	end

	def latest_episode( options = {}, t = Time.now.utc )
		opts = Episode.find_available_episode_for_show_options( self.id, {}, t )
		opts = Episode.join_episodes_season_and_episode_number( opts )
    opts.merge(options)
		# applies the manual ordering
		Episode.first( opts.merge({ :order => Episode.order_episodes_reverse_season_and_episode_number.collect{|c,d| "#{c} #{d}"}.join(',') }) )
	end

	def count_available_episodes( t = Time.now.utc )
		opts = Episode.find_available_episode_for_show_options(self.id,{},t)
		opts.delete(:select)
		Episode.count( opts )
	end

	def count_premium_episodes( t = Time.now.utc )
		count_available_episodes( t ) - count_public_episodes( t )
	end

	def count_public_episodes( t = Time.now.utc )
		opts = Episode.find_available_episode_for_show_options( self.id, {}, t )
		opts[:joins] += ' INNER JOIN episode_free_schedule_dates ON episode_free_schedule_dates.exclusivity_id = episodes.id'
		conds = EpisodeFreeScheduleDateSet.conditions_for_range_including( EpisodeFreeScheduleDate.table_name, nil, t )
		opts[:conditions][0] += ' AND ' + conds[0]
		opts[:conditions].concat( conds[1..-1] )
		opts[:select] = nil
		Episode.count( opts )
  end

  def count_episodes( t = Time.now.utc )
    Episode.count( Episode.find_available_episode_for_show_options( self.id, {}, t ) )
  end


end
