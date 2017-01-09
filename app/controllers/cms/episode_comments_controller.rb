class Cms::EpisodeCommentsController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View


	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time
	require_post_method_for :destroy, :update


	def episode_pagination( episode )
		CW::Pagination::Model::ActiveRecord.new( self, 'EpisodeComment', CW::SortOrder.desc('created_at'), {:conditions => ['episode_id = ?',episode.id]}, Setting['vms-protected-items-per-page'].value_typed )
	end; protected :episode_pagination

	def episode
		@episode = Episode.find( params[:id] )
		@pagination = episode_pagination(@episode)
	end

	def info
		@comment = EpisodeComment.find params[:id]
		@episode = @comment.episode
		@pagination = episode_pagination(@comment.episode)
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'edit', { :action => 'edit', :id => @comment.id }, {:title => 'Edit this comment'}
			s.link 'destroy', { :action => 'destroy_confirm', :id => @comment.id }, {:title => 'Create a new category'}
		}
	end

	def edit
		@comment = EpisodeComment.find params[:id]
		@episode = @comment.episode
		@pagination = episode_pagination(@comment.episode)
	end

	def update
		@comment = EpisodeComment.find params[:id]
		@episode = @comment.episode
		@pagination = episode_pagination(@comment.episode)
		@comment.visible = params[:comment]['visible']
		if @comment.update_attributes( params[:comment] )
			flash[:msg] = "Comment updated"
			redirect_to :action => 'info', :id => @comment.id
		else
			render :action => 'edit'
		end
	end

	def destroy_confirm
		@comment = EpisodeComment.find params[:id]
		@episode = @comment.episode
		@pagination = episode_pagination(@comment.episode)
	end

	def destroy
		@comment = EpisodeComment.find params[:id]
		@episode = @comment.episode
		@pagination = episode_pagination(@comment.episode)
		pn = @pagination.page_number_of_item( @comment )
		@comment.destroy
		flash[:msg] = 'Comment removed'
		redirect_to :action => 'episode', :id => @comment.episode_id, :page => pn
	end

end
