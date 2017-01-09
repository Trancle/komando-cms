class EpisodeCommentReport < ActiveRecord::Base
	belongs_to :episode_comment
	belongs_to :request_log

	REASONS = %w(spam offensive off-topic).freeze

	validates_numericality_of :request_log_id, :only_integer => true, :allow_nil => true
	validates_numericality_of :episode_comment_id, :only_integer => true
	validates_length_of :reason, :allow_nil => true, :maximum => 256
	validates_inclusion_of :reason, :in => REASONS

# this is the only acceptible mass-assignment variable
	attr_accessible :reason

	def validate
		begin
			episode = EpisodeComment.find( self.episode_comment_id )
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :episode_comment_id, 'does not exist' )
		end

	end


	PUBLIC_RENDER_OPTIONS = { :only => [:reason] }.freeze

	def to_public_xml( opts = {} )
		self.to_xml( opts.merge( PUBLIC_RENDER_OPTIONS ) )
	end

	def to_public_json( opts = {} )
		self.to_json( opts.merge( PUBLIC_RENDER_OPTIONS ) )
	end

	def dismiss( user_id )
		self.review_assigned_to_user_id = user_id unless self.review_assigned_to_user_id.nil?
		self.reviewed = true
	end

	def self.dismiss_all_for_comment( episode_comment_id, user_id )
		ret = []
		transaction do
			ret = find(:all, :conditions => { :episode_comment_id => episode_comment_id } )
			ret.each do |report|
				report.dismiss( user_id )
				report.save
			end
		end
		ret
	end

end
