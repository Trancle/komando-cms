class CommentController < ApplicationController
	layout 'comments'

# login is required for everything except what is listed
	skip_filter :require_login, :only => [:episode,:new_episode_discussion,:new_episode_review,:detail,:new_episode_comment_spam_report,:new_episode_comment_offensive_report,:new_episode_comment_off_topic_report,:new_episode_disucssion_ajax]
# this is not an administrator section
	skip_filter :require_administrator_user
  skip_filter :default_caching_policy, :except => [:episode,:detail]

	hide_action :require_episode_and_show_available

	require_post_method_for :create_episode_discussion, :create_episode_comment_report

# log requests for discussions
# require login to create discussions and sitch
	before_filter :require_login, :except => [:episode,:new_episode_discussion,:new_episode_review,:detail,:new_episode_comment_spam_report,:new_episode_comment_offensive_report,:new_episode_comment_off_topic_report]

# returns the comment listing for an episode
	def episode
		limit = params[:limit] || Setting['vms-protected-visible-episode-comment-count'].value_typed
		start_at_id = params[:start_at_id]

		# ensure no one abuses the system
		limit = Setting['vms-protected-visible-episode-comment-count'].value_typed if limit > Setting['vms-protected-visible-episode-comment-count'].value_typed
		@episode = Episode.find( params[:id], :readonly => true )
		if !@episode.available? or !@episode.show.available?
			redirect_to home_url and return
		end
		opts = {:limit => limit, :order => 'id DESC', :readonly => true}
		opts[:conditions] = ['id < ?',start_at_id] unless start_at_id.nil?
		@comments = @episode.episode_comments.find( :all, opts )
		user_ids = @comments.collect{|c| c.user_id }.uniq
		@users = User.all( :conditions => { :id => user_ids }, :readonly => true )
		respond_to do |format|
			format.json do
				render( :json => '{ comments: {' + @comments.collect{|x| x.to_json}.join(',') + '}, users: {' + @users.collect{|x| x.to_public_json}.join(',') + '} }' ) and return
			end
		end
	end

	def new_episode_discussion
		begin
			@episode = Episode.find( params[:id], :readonly => true )
			return false unless require_episode_and_show_available( @episode, @episode.show )

			@episode_comment = EpisodeCommentDiscussion.new( :user_id => session[:user_id], :episode_id => @episode.id )
			@episode_comment.parent_comment_id = @parent_comment.id if @parent_comment
			@episode_comment.episode_id = @episode.id
			@episode_comment.user_id = session[:user_id]
			@episode_comment.parent_comment_id = params[:episode_comment]['parent_comment_id'] if params[:episode_comment] and params[:episode_comment]['parent_comment_id']
		rescue ActiveRecord::RecordNotFound => s
			render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
		end
	end

	def create_episode_discussion
		begin
			new_episode_discussion
			@episode_comment.attributes= params[:episode_comment]
			#@episode_comment.request_log_id = self.request_log.id
			if @episode_comment.save
				respond_to do |format|
					format.html { redirect_to :action => 'detail', :id => @episode_comment }
					format.json { render :json => '{ "success": true }' }
				end
			else
				respond_to do |format|
					format.html { render :action => 'new_episode_discussion' }
					format.json { render :json => '{ "success": false, "errors": ' + @episode_comment.errors.to_json + '}' }
				end
			end
		rescue ActiveRecord::RecordNotFound => s
			render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
		end
	end

	def new_episode_review
		begin
			@episode = Episode.find( params[:id], :readonly => true )
			unless require_episode_and_show_available( @episode, @episode.show )
				# 404 if not found
				render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
			else
				@episode_comment = EpisodeCommentReview.new( :user_id => session[:user_id], :episode_id => @episode.id )
				@episode_comment.parent_comment_id = @parent_comment.id if @parent_comment
				@episode_comment.episode_id = @episode.id
				@episode_comment.user_id = session[:user_id]
				@episode_comment.parent_comment_id = params[:episode_comment]['parent_comment_id'] if params[:episode_comment] and params[:episode_comment]['parent_comment_id']
			end
		rescue ActiveRecord::RecordNotFound => s
			render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
		end
	end

	def create_episode_review
		new_episode_review
		@episode_comment.attributes= params[:episode_comment]
#@episode_comment.request_log_id = self.request_log.id
		if @episode_comment.save
			redirect_to :action => 'detail', :id => @episode_comment
		else
			render :action => 'new_episode_review'
		end
	end


	def detail
		begin
			@episode_comment = EpisodeComment.find params[:id], :readonly => true
			@episode = @episode_comment.episode
			@show = @episode_comment.episode.show
			respond_to do |format|
				format.html
				format.json { render :json => @episode_comment.to_public_json }
			end
		rescue ActiveRecord::RecordNotFound => s
			render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
		end
	end

	def new_episode_comment_spam_report
		begin
			@episode_comment = EpisodeComment.find params[:id], :readonly => true
			if @episode_comment.nil?
				render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
			else
				@episode = @episode_comment.episode
				@episode_report = EpisodeCommentReport.new( :episode_comment_id => @episode_comment.id )
				respond_to do |format|
					format.html { render :action => 'new_episode_comment_report' }
					format.xml { render :xml => @episode_report.to_public_xml }
					format.json { render :json => @episode_report.to_public_json }
				end
			end
		rescue ActiveRecord::RecordNotFound => s
			render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
		end
	end
	def new_episode_comment_offensive_report
		begin
			@episode_comment = EpisodeComment.find params[:id], :readonly => true
			if @episode_comment.nil?
				render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
			else
				@episode = @episode_comment.episode
				@episode_report = EpisodeCommentReport.new( :episode_comment_id => @episode_comment.id )
				respond_to do |format|
					format.html { render :action => 'new_episode_comment_report' }
					format.xml { render :xml => @episode_report.to_public_xml }
					format.json { render :json => @episode_report.to_public_json }
				end
			end
		rescue ActiveRecord::RecordNotFound => s
			render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
		end
	end
	def new_episode_comment_off_topic_report
		begin
			@episode_comment = EpisodeComment.find params[:id], :readonly => true
			if @episode_comment.nil?
				render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
			else
				@episode = @episode_comment.episode
				@episode_report = EpisodeCommentReport.new( :episode_comment_id => @episode_comment.id )
				respond_to do |format|
					format.html { render :action => 'new_episode_comment_report' }
					format.xml { render :xml => @episode_report.to_public_xml }
					format.json { render :json => @episode_report.to_public_json }
				end
			end
		rescue ActiveRecord::RecordNotFound => s
			render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
		end
	end

	def create_episode_comment_report
		begin
			@episode_comment = EpisodeComment.find params[:id]
			if @episode_comment.nil?
				render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
			else
				@episode = @episode_comment.episode
				@episode_report = EpisodeCommentReport.new( params[:episode_report] )
				@episode_report.episode_comment_id = @episode_comment.id
	#@episode_report.request_log_id = self.request_log.id
				@episode_report.save
				respond_to do |format|
					format.html { redirect_to( :controller => 'watch', :action => @episode_comment.episode.id ) }
					format.xml { render :xml => @episode_report.errors.to_xml }
					format.json { render :json => @episode_report.errors.to_json }
				end
			end
		rescue ActiveRecord::RecordNotFound => s
			render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404, :layout => false ) and return
		end
	end


	def new_episode_discussion_ajax
		new_episode_discussion
		render :action => 'new_episode_discussion', :layout => false
	end







	def require_episode_and_show_available( episode, show )
		if !show.available?
			redirect_to home_url and return false
		end
		if !episode.available?
			redirect_to url_to_show( show.scheduled_version_current_or_last_version ) and return false
		end
		unless session_user.can_comment?
			redirect_to url_to_episode( show.scheduled_version_current_or_last_version, episode.current_version_or_latest ) and return false
		end
		true
	end

end
