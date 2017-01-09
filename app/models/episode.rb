require File.dirname(__FILE__) + '/../modules/add_xml_json_to_taggables.rb'
require File.dirname(__FILE__) + '/../modules/ws_taggable.rb'
class Episode < ActiveRecord::Base
	include CW::ActsAs::Versioned::Stub
	def self.versioned_model_klass; "EpisodeVersion".constantize; end
	def self.taggable_base_klass; "EpisodeTag".constantize; end
	def self.taggable_link_klass; "LinkEpisodeWithEpisodeTag".constantize; end
	include CW::ActsAs::Taggable::Taggable
	TagList.send( :include, AddXmlJsonToTaggables )
	include CW::ActsAs::Ordered::Model
	def self.acts_as_ordered_exclusivity_attribute_name; :show_id; end

	include CW::ActsAs::Cacheable

  include WS::Taggable

	belongs_to :show
	has_many :episode_publish_schedule_dates, :foreign_key => :exclusivity_id, :dependent => :destroy
	has_many :episode_free_schedule_dates, :foreign_key => :exclusivity_id, :dependent => :destroy
	has_many :episode_parts, :dependent => :destroy
	has_many :episode_comments, :dependent => :destroy
	has_many :episode_versions, :foreign_key => :version_stub_id, :dependent => :destroy
  belongs_to :current_version, :class_name => 'EpisodeVersion', :foreign_key => :current_version_id
  has_many :video_content_names, :through => :episode_parts

  has_many :taggings, :class_name => 'EpisodeTagging', :include => 'tag', :dependent => :destroy
  has_many :tags, :class_name => 'EpisodeTag', :through => :taggings, :source => 'tag'

  has_many :show_dl_episodes, :dependent => :destroy

	validates_presence_of :show_id
	validates_numericality_of :show_id, :allow_nil => true, :only_integer => true

	validates_numericality_of :comment_count, :only_integer => true

	liquid_methods :published_datetime
	liquid_methods :comment_count

	attr_protected :ts_index

	def published_datetime
		d = self.read_attribute( :published_datetime )
		return self.created_at if d.nil?
		d
  end

  def current_version_or_latest
    self.current_version || EpisodeVersion.first(:conditions => ['version_stub_id = ?',self.id])
  end

	
	acts_as_cacheable_cache_method( :version_count )

	def free?( t = Time.now.utc )
		EpisodeFreeScheduleDateSet.new( self.id ).includes?(t)
	end
	alias :is_free :free?

	def available?( t = Time.now.utc )
	  self.published and !self.current_version.nil? and EpisodePublishScheduleDateSet.new( self.id ).includes?(t) and !self.episode_parts.empty? and self.episode_parts.detect{|x| x.video_content_name and !x.video_content_name.video_contents.empty? }
	end

# published date is ignored. This is for scheduling file deletion
	def will_be_available_in_future?( t = Time.now.utc )
		test = EpisodePublishScheduleDate.new( :start_at => t, :end_at => nil )
		test.exclusivity_id = self.id
		self.show.will_be_available_in_future?( t ) and test.will_overlap?
  end


  def next_available_episode( offset = 1 )
    return self if offset.eql?(0)
    opts = self.class.find_available_episode_for_show_options( self.show.id, {:offset => offset.abs - 1 } )
    opts[:conditions][0] << ' AND episodes.acts_as_ordered_order ' + (offset > 0 ? '> ?' : '< ?' )
    opts[:conditions] << self.acts_as_ordered_order
    opts[:order] = offset > 0 ? self.class.order_options('ASC')[:order] : self.class.order_options('DESC')[:order]
    #raise offset.inspect + ':' + opts.inspect if offset < 1
    self.class.first( opts )
  end


	def self.find_available_episode_options( opts = {}, t = Time.now.utc )
		o = {}
    o[:conditions] = ['']
	o[:joins] = ''

		# view only published shows with a current version
		o[:conditions][0] += 'episodes.published = ? and episodes.current_version_id IS NOT NULL'
		o[:conditions] << true

		# Only episodes that are current
               c = EpisodePublishScheduleDateSet.conditions_for_range_including( 'episode_publish_schedule_dates', nil, t )
               o[:conditions][0] += " AND EXISTS ( SELECT * FROM episode_publish_schedule_dates WHERE #{c[0]} AND episode_publish_schedule_dates.exclusivity_id = episodes.id )"
               o[:conditions].concat( c[1..-1] )

# Episode MUST have at least 1 episode part, and that needs at least 1 video_content_name and THAT needs at least 1 video_content
		o[:conditions][0] += " AND EXISTS ( SELECT * FROM video_contents INNER JOIN video_content_names ON video_content_names.id = video_contents.pretty_name_id INNER JOIN episode_parts ON episode_parts.video_content_name_id = video_content_names.id WHERE episode_parts.episode_id = episodes.id )"

		o[:joins] += ' INNER JOIN shows ON shows.id = episodes.show_id '
		# end show exclusion

		# Enforce manual ordering
#o.merge( Episode.order_options )

		# Allow user to further customize
		o.merge( opts )
  end

  def self.find_episodes_for_show_options( show_id, opts = {}, show = nil )
    c = opts
    c[:conditions] = [''] unless c.has_key?(:conditions)
    show = show || Show.find(show_id)
    case show.class.name
      when 'Show'
        c[:conditions][0] += ' AND ' unless c[:conditions][0].empty?
        c[:conditions][0] += 'episodes.show_id = ?'
        c[:conditions] << show_id
      when 'ShowOfTag'
        tag_names = show.tags.collect{|t|t.tag}
        unless tag_names.empty?
          tag_ids_from_episodes = EpisodeTag.all( :select => 'id', :conditions => ["tag IN (#{tag_names.collect{'?'}.join(',')})"].concat(tag_names) ).collect{|t| t.id}
          opts = Episode.scope_with_tags( tag_ids_from_episodes )
          c[:conditions][0] += ' AND ' unless c[:conditions][0].empty?
          c[:conditions][0] += opts[:conditions].shift
          c[:conditions].concat(opts[:conditions])
        else
          c[:conditions][0] += ' AND ' unless c[:conditions][0].empty?
          c[:conditions][0] += 'false' # condition will never be true, select NO episodes
        end
      else
        raise 'Unknown show type: ' + show.class.name
    end
    c
  end

	def self.find_available_episode_for_show_options( show_id, opts, t = Time.now.utc, show = nil )
		c = find_available_episode_options( opts, t )
    c = find_episodes_for_show_options( show_id, c, show )
		c
  end

  def self.exclude_episodes_with_ids( opts, episode_ids = [] )
    episode_ids = [episode_ids] unless episode_ids.is_a?(Array)
    conds = ["episodes.id NOT IN (#{episode_ids.map{|e| '?' }.join(',')})"].concat( episode_ids )
    merge_options( opts, { :conditions => conds } )
  end

	def self.join_episodes_season_and_episode_number( opts = {} )
		n = { :joins => 'INNER JOIN episode_versions ON episode_versions.id = episodes.current_version_id', :order => 'episode_versions.season_number DESC, episode_versions.episode_number DESC, episodes.created_at DESC' }
		if opts[:joins].nil?
		 	opts[:joins] = n[:joins]
		else
			opts[:joins] += ' ' + n[:joins]
		end
		opts
	end

	def self.order_episodes_reverse_season_and_episode_number
		(CW::SortOrder.new - 'episode_versions.season_number' - 'episode_versions.episode_number').concat(order_sort_order.invert) - 'episodes.created_at'
	end

	def full_urlized_title
		self.show.scheduled_version_current_or_last_version_cache.url_title + '-' + self.current_version_or_latest.url_title
	end

	def are_comments_enabled?( t = Time.now.utc )
		self.show.are_episode_comments_enabled?(t) and self.comments_enabled and Setting['vms-protected-user-input-enabled'].value_typed
	end

	def is_user_tagging_enabled?( t = Time.now.utc )
		self.show.is_episode_user_tagging_enabled?(t) and self.user_tagging_enabled and Setting['vms-protected-user-input-enabled'].value_typed
	end

	def total_length_in_seconds(video_contents_p = nil)
    self.class.total_length_in_seconds( video_contents_p || self.video_contents )
  end

  def self.total_length_in_seconds( video_contents )
    tot = 0.0
    video_contents.each do |vc|
      tot += vc.length_in_seconds
    end
    tot
  end

  # preload and save.
  def video_contents(force = false)
    if force or @video_contents.nil?
      @video_contents = VideoContent.all( :select => 'length_in_seconds', :conditions => ['video_contents.pretty_name_id IN ( SELECT video_content_name_id FROM episode_parts WHERE episode_parts.episode_id = ? )',self.id] )
    end
    @video_contents
  end

  def video_contents=( vc )
    @video_contents = vc
  end

	def total_length_as_hh_mm_ss( video_contents_p = nil )
    sec = self.total_length_in_seconds( video_contents_p ).to_i
    h = sec/3600
    mrh = (sec%3600)
    m = mrh/60
    s = sec%60

		[h,m,s]
  end

  def total_length_colonized( video_contents_p = nil )
    comp = total_length_as_hh_mm_ss( video_contents_p )
    # remove all leading 0 components (ignore)
    until comp.empty?
      c = comp.shift
      unless c.eql?(0)
        comp.unshift(c)
        break
      end
    end
    v = [comp.first] # no leading zero on the first component
    v.concat((comp[1..-1]||[]).collect{|c| '%02d' % c })
    v.collect.join(':')
  end

	def current_free_range( t = Time.now.utc )
		EpisodeFreeScheduleDateSet.new( self.id ).find_range_including( t )
	end

	def current_available_range( t = Time.now.utc )
		EpisodePublishScheduleDateSet.new( self.id ).find_range_including( t )
	end


	# Gets a lot of detailed information about this episode
	def inspect_deep
		puts self.inspect
		puts "Versions: #{self.versions.count}"
		puts self.versions.inspect
  end

  def required_levels_as_a
    (required_levels || '').squeeze(' ').split(' ')
  end


  def self.scope_with_tags( episode_tag_id_array )
    # Lookup tags, we need EpisodeTag ID's
    unless episode_tag_id_array.empty?
      { :conditions => ["EXISTS (SELECT * FROM episode_taggings WHERE episodes.id = episode_taggings.episode_id AND episode_taggings.tag_id IN (#{episode_tag_id_array.collect{'?'}.join(',')}) )"].concat(episode_tag_id_array) }
    else
      { :conditions => ["false"] }
    end
  end


  def related_episode_options( options = {} )
    options[:limit] = 10 unless options[:limit]
    my_tags = self.tags
    Episode.find_available_episode_for_show_options( self.show_id, Episode.scope_with_tags( my_tags.map{|t|t.id} ).merge(options) )
  end

  def related_episodes( options = {} )
    Episode.all(Episode.exclude_episodes_with_ids(related_episode_options, self.id))
  end

  def self.random_episodes_older_than_options( older_than )
    { :conditions => ["episodes.published_datetime < ?", older_than], :order => 'random()' }
  end



  # FIXME
  def self.merge_options( a, b )
    opts = a.dup

    b.each_pair do |k,v|
      # Key then Val
      case opts[k].class.name
        when 'Array' # destination is array
          conds = opts[k].first
          conds << ' AND ('
          case v.class.name
            when 'Array' # source is array: easy, concat
              conds << v.first
              opts[k].concat v[1..-1]
            when 'String' # source is string: easy, append
              conds << v
          end
          conds << ')'
          opts[k][0] = conds
        when 'String' # destination is string
          case v.class.name
            when 'Array' # source is array, harder, make destination an array, too
              opts[k] = [opts[k] + ' AND ( ' + v.first + ' )']
              opts[k].concat v[1..-1]
            when 'String' # source is string, easy, append
              opts[k] = opts[k] + ' AND ( ' + v + ' )'
          end
        else
          opts[k] = v # Simply override if in source
      end
    end

    opts
  end


end
