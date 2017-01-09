class Admin::UserInputBansController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :destroy, :create, :update

	def index
		list
		render :action => 'list'
	end

	def list_pagination( t = Time.now.utc )
		conds = UserInputBanScheduleRange.find_first_containing_options( 'user_input_ban_schedule_ranges', nil, t )[:conditions]
		CW::Pagination::Model::ActiveRecord.new( self, 'User', CW::SortOrder.asc('username').asc('id'), {:conditions => ["EXISTS ( SELECT * FROM user_input_ban_schedule_ranges WHERE user_input_ban_schedule_ranges.exclusivity_id = users.id AND #{conds.shift} )"].concat(conds)}, Setting['vms-protected-items-per-page'].value_typed )
	end
	protected :list_pagination
	def list
		@user_pag = list_pagination
	end

	def ban_pagination( user )
		CW::Pagination::Model::ActiveRecord.new( self, 'UserInputBanScheduleRange', CW::SortOrder.asc('start_at').asc('id'), {:conditions => ['exclusivity_id = ?',user.id]}, Setting['vms-protected-items-per-page'].value_typed )
	end
	protected :ban_pagination
	def user
		@user = User.find( params[:id] )
		@user_pag = list_pagination
		@ban_pag = ban_pagination( @user )
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'ban', {:action => 'new', :id => @user.id}, {:title => 'Ban this user'}
		}.section('View') {|s|
			s.link 'info', {:controller => 'admin/users', :action => 'info', :id => @user.id}, {:title => 'View more information about this user'}
		}
	end
	

	def new
		@user_pag = list_pagination
		@user = User.find( params[:id] )
		@ban = UserInputBanScheduleRange.new
	end

	def create
		@user_pag = list_pagination
		@user = User.find( params[:id] )
		@ban = UserInputBanScheduleRange.new( params[:ban] )
		@ban.exclusivity_id = @user.id
		if @ban.save
			flash[:msg] = 'User input ban created'
			redirect_to :action => 'user', :id => @user.id
		else
			render :action => 'new'
		end
	end

	def show
		@user_pag = list_pagination
		@ban = UserInputBanScheduleRange.new( params[:id] )
		@user = @ban.user
		@ban_pag = ban_pagination( @user )
	end

	def edit
		@user_pag = list_pagination
		@ban = UserInputBanScheduleRange.find( params[:id] )
		@user = @ban.user
		@ban_pag = ban_pagination( @user )
	end

	def update
		@user_pag = list_pagination
		@ban = UserInputBanScheduleRange.find( params[:id] )
		@user = @ban.user
		@ban_pag = ban_pagination( @user )
		if @ban.update_attributes( params[:ban] )
			flash[:msg] = 'User input ban modified'
			redirect_to :action => 'user', :id => @ban.user.id
		else
			render :action => 'edit'
		end
	end

	def destroy_confirm
		@user_pag = list_pagination
		@ban = UserInputBanScheduleRange.find( params[:id] )
		@user = @ban.user
		@ban_pag = ban_pagination( @user )
	end

	def destroy
		@user_pag = list_pagination
		@ban = UserInputBanScheduleRange.find( params[:id] )
		@user = @ban.user
		@ban_pag = ban_pagination( @user )
		pn = @ban_pag.page_number_of_item( @ban )
		@ban.destroy
		flash[:msg] = 'Ban lifted'
		redirect_to :action => 'user', :id => @ban.user.id, :page => pn
	end

end
