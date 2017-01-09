class EpisodeComment < ActiveRecord::Base
	include CW::ActsAs::Blacklistable::Blacklistable
	belongs_to :user
	belongs_to :episode
	belongs_to :parent, :class_name => 'EpisodeComment', :foreign_key => 'parent_comment_id'
	has_many :children, :class_name => 'EpisodeComment', :foreign_key => 'parent_comment_id', :dependent => :destroy, :order => 'created_at DESC'

	validates_presence_of :user_id
	validates_presence_of :episode_id

	validates_numericality_of :user_id, :only_integer => true, :allow_nil => true
	validates_numericality_of :episode_id, :only_integer => true, :allow_nil => true
	validates_numericality_of :parent_comment_id, :only_integer => true, :allow_nil => true

	validates_length_of :title, :in => 2..150

	validates_length_of :body, :in => 4..2000

# protects variables from mass assignment that shouldn't be tampered with by common users
	attr_accessible :title, :body
# as you can see, only the title and body can be edited
	attr_readonly :user_id, :episode_id, :created_at


	def user_or_anonymous
		u = self.user
		return UserAnonymous.new if u.nil?
		u
	end

	def has_parent?; return !self.parent_comment_id.nil?; end

# allows one to change the user id of a comment, even though it's marked as read-only, you can do this programmatically only
	def change_user_id_overriding_readonly( user_id )
		self.user_id = user_id
		self.class.connection.update( self.class.send( :sanitize_sql_array, ["UPDATE #{self.class.table_name} SET user_id = ? WHERE id = ?",self.user_id,self.id] ) )
		self
	end

	def validate
		# allows administrators to configure comments, despite bad words and availability
		return true if !@bypass_special_validations.nil? and @bypass_special_validations

		# need checks for bad words in title and body
		validates_blacklisted_input

		# ensure user is not on a ban-list
		validates_is_on_banlist unless

		begin
			# check for existence of episode
			episode = Episode.find( self.episode_id )
			# check for comments being enabled
			unless self.user.is_a?(UserAdministrator)
				unless episode.are_comments_enabled?
					# skip for administrators
					self.errors.add_to_base( 'Sorry, commenting has been disabled for this episode' ) 
				end
				unless episode.available?
					self.errors.add_to_base( 'Sorry, this episode is no longer available' ) 
				end
			end
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :episode_id, "does not exist" )
		end

		begin
			if self.has_parent?
				# parent must exist
				parent = EpisodeComment.find( self.parent_comment_id )
				# parent must be visible
				unless parent.visible
					self.errors.add( :visible, 'parent comment is not visible' )
				end
				# if comment has a parent, comment's parent must be for same episode
				unless parent.episode_id.eql?( self.episode_id )
					self.errors.add( :parent_comment_id, "is not attached to the same episode" )
				end
				# make sure the parent isn't already nestd. We support only 1 level of message/reponse
				unless parent.parent_comment_id.nil?
					self.errors.add( :parent_comment_id, "already has a parent comment" )
				end
			end
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :parent_comment_id, "does not exist" )
		end

		cooldown = Setting['vms-protected-user-comment-cool-down-time']
		# enforce the cool-down period, if set
		if cooldown and !cooldown.value_typed.eql?0
			if EpisodeComment.exists?( ['created_at > ? AND user_id = ?',Time.now.utc - cooldown.value_typed.seconds, self.user_id] )
				self.errors.add_to_base "You're posting comments too frequently. Please wait a while between comments"
			end
		end
	end

	def validates_blacklisted_input
		# any matches made will be reported on the validations, just as expected :-)
		matches = self.class.blacklistable_find_matches_against( UserInputBlacklist, { :title => self.title, :body => self.body } )
		matches.each_pair do |k,v|
			t = v.slice 0..10
			t.each do |banned|
				self.errors.add( k, " contains '#{banned}' and is not allowed" )
			end
		end
	end

	def validates_is_on_banlist( t = Time.now.utc )
		if UserInputBanSchedule.new(self.user_id).includes?( t )
			# User is on an input ban list. DENY!
			self.errors.add_to_base( "You are, presently, forbidden from contributing input." )
		end
	end

	def after_create
		Episode.increment_counter( :comment_count, self.episode_id )
	end

	def before_destroy
		Episode.decrement_counter( :comment_count, self.episode_id )
	end

	def friendly_type_name
		self.class.name.sub('EpisodeComment','')
	end

	def page_anchor_id
		"episode-comment-id-#{self.id}"
	end

	PUBLIC_RENDER_OPTIONS = { :only => [:title,:body,:episode_id,:created_at,:id] }.freeze

	def to_public_xml( opts = {} )
		self.to_xml( opts.merge( PUBLIC_RENDER_OPTIONS ) ) do |xml|
			xml.poster << self.user_or_anonymous.to_public_xml( :skip_instruct => true )
		end
	end


	def to_public_json( opts = {} )
		self.to_json( opts.merge( PUBLIC_RENDER_OPTIONS ) )
	end

	def can_post_reply?( controller )
		self.class.can_post_comment?(controller) and !self.user_or_anonymous.id.eql?controller.session_user.id and self.parent_comment_id.nil?
	end

	def self.can_post_comment?( controller )
		controller.is_logged_in?
	end

	def last_children( c )
		self.children.find( :all, :limit => c )
	end

	def has_more_children_than?( c )
		self.children.count() > c
	end



	def self.find_comments_with_unreviewed_reports_options( opts = {} )
		{ :select => "#{self.table_name}.*", :conditions => CW::Condition.new(["EXISTS ( SELECT #{EpisodeCommentReport.table_name}.id FROM #{EpisodeCommentReport.table_name} WHERE #{EpisodeCommentReport.table_name}.episode_comment_id = #{EpisodeComment.table_name}.id AND #{EpisodeCommentReport.table_name}.reviewed = ? AND #{self.table_name}.visible = ? )",false,true]).done }.merge( opts )
	end

	def self.find_comments_with_unreviewed_reports_order_options_by_most_reports( opts = {} )
		{ :order => 'report_count DESC' }.merge( opts )
	end

	def report_counts
		ret = {}
		opts = {}
		opts[:conditions] = ['reviewed = ? AND episode_comment_id = ?',false,self.id]
		opts[:group] = 'reason'
		EpisodeCommentReport.count( opts ).each do |report|
			ret[report[0]] = report[1]
		end
		ret
	end

	def save_bypass_special_validations
		@bypass_special_validations = true
		r = save
		@bypass_special_validations = false
		r
	end

end
