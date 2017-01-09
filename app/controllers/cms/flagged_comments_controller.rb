class Cms::FlaggedCommentsController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :hide_comment, :dismiss_complaints_for_comment

	def list_pagination
		CW::Pagination::Model::ActiveRecord.new( self, 'EpisodeComment', CW::SortOrder.asc('created_at'), EpisodeComment.find_comments_with_unreviewed_reports_options(), Setting['vms-protected-items-per-page'].value_typed ).add_join_accessor( 'report_count', Proc.new{|o| o.id} )
	end; protected :list_pagination

	def index
		@pagination = list_pagination
	end

	def comment
		@comment = EpisodeComment.find( params[:id] )
		@pagination = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'edit', { :controller => 'cms/episode_comments', :action => 'edit', :id => @comment.id }, {:title => 'Change this comment'}
			s.link 'hide comment', { :action => 'hide_comment', :id => @comment.id }, {:title => 'Makes this comment invisible to the public, effectively removing it from the site'}
			s.link 'dismiss complaints', { :action => 'dismiss_complaints_for_comment', :id => @comment.id }, {:title => 'Marks this comment as being OK and deletes the complaints against this comment'}
		}
	end

	def hide_comment
		@comment = EpisodeComment.find params[:id]
		@comment.visible = false
		if @comment.save_bypass_special_validations
			flash[:msg] = "That comment is now hidden"
			redirect_to :action => 'index'
		else
			render :action => 'comment'
		end
	end

	def dismiss_complaints_for_comment
		EpisodeCommentReport.dismiss_all_for_comment( params[:id], session_user.id )
		flash[:msg] = "OK, all reports for that comment are dismissed"
		redirect_to :action => 'index'
	end


end
