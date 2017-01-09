class Admin::MaintenanceController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	def index
	end

	require_post_method_for :remove_unsed_video

	def remove_unused_video_confirm
		@now = Time.now.utc
		@files = VideoContentName.find_all_safe_to_delete( @now, :order => 'pretty_name' )
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.button 'remove', { :action => 'remove_unused_video' }, {:class => 'button'}
		}
	end

	def remove_unused_video
		@now = Time.parse( params[:now] )
		VideoContentName.destroy_all_safe_to_delete( @now )
		redirect_to( :action => 'index' )
	end

	def remove_unreferenced_video_content
		conds = ['']
		if params[:id]
			conds[0] << 'video_contents.id = ? AND '
			conds << params[:id]
		end
		@contents = VideoContent.find(:all, :conditions => conds[0] << 'NOT EXISTS ( SELECT * FROM video_content_names WHERE video_content_names.id = video_contents.pretty_name_id )', :order => 'id' )
		if request.post?
			raise 'here'
		end
	end

end
