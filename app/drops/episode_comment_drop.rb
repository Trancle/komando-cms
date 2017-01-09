class EpisodeCommentDrop < BaseDrop

	def initialize( comment, controller, time = Time.now.utc, options = {} )
		@comment = show
		@time = time
		@controller = controller
		@options = options
	end

	def can_reply?
		@comment.can_post_reply?( @controller )
	end

	def reply_to_comment_link
		reply_to_comment_id = @comment.id
		reply_to_comment_id = @comment.parent_comment_id if @comment.parent_comment_id

		s = <<EOD
<div class="episode-comment-reply-container">
<p>#{ link_to( 'reply', { :action => 'new_episode_discussion', :id => comment.episode.id, :episode_comment => {:parent_comment_id => reply_to_comment_id} }, onclick => "$('new-episode-comment').show(); $('episode_comment_parent_comment_id').value = #{reply_to_comment_id}" ) }</p>
</div>
EOD
		s
	end


	def postername
		@comment.user_or_anonymous.username
	end

	def title
		h( strip_tags( @comment.title ) )
	end

	def body
		simple_format( h( strip_tags( @comment.body ) ) )
	end

	def report_buttons
		[]
	end

	def rating_buttons
	end

	def created_at
		@comment.created_at
	end

	def created_at_ago_in_words
		distance_of_time_in_words_to_now( @comment.created_at )
	end

	def replied_ago_in_words
		if @comment.parent
			distance_of_time_in_words( @comment.created_at, @comment.parent.created_at )
		end
	end

	def reply_button
	end

	def has_children
		!@comment.children.empty?
	end

	def children
		@comment.last_children( @options[:child_limit] || 100 )
	end

end
