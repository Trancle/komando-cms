class Admin::UsersController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :wipe


	def index
		list
		render :action => 'list'
	end

	def list_pagination
    if params[:email_filter]
      # filter by email
      CW::Pagination::Model::ActiveRecord.new( self, 'User', CW::SortOrder.asc('username'), {:conditions => ['email = ?',params[:email_filter]]}, Setting['vms-protected-items-per-page'].value_typed )
    else
      CW::Pagination::Model::ActiveRecord.new( self, 'User', CW::SortOrder.asc('username'), {}, Setting['vms-protected-items-per-page'].value_typed )
    end
  end
  protected :list_pagination
	def list
	@pagination = list_pagination
#@pagination, @users = pagination_of_simple( User, Pagination::Book.new( Setting['vms-protected-items-per-page'].value_typed ), { :order => 'username' } )
	end

	def info
		@user = User.find( params[:id] )
		@pagination = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'wipe', { :action => 'wipe_confirm', :id => @user.id }, { :title => 'Creates a new setting' }
		}.section( 'View' ) {|s|
			s.link 'input ban', { :controller => 'admin/user_input_bans', :action => 'user', :id => @user.id }, {:title => 'See if this user is disallowed from providing comments/tag suggestions'}
		}
  end

  def edit
    @user = User.find( params[:id] )
    if request.post?
      allowed_keys = %w(email type enabled username uid)
      # explicitly set password, but only if supplied
      @user.password = params[:user]['password'] if params[:user]['password'] and !params[:user]['password'].empty? # password reset
      allowed_params = {}
      params[:user].each_pair{|key,val| allowed_params[key] = val if allowed_keys.include?(key) }
      if @user.update_attributes( allowed_params )
        # update successful
        redirect_to :action => 'info', :id => @user.id
      else
        # not updated, render the form
      end
    else
      # nothing to do, render the form
    end
  end

  def new
    @user = User.new
    if request.post?
      allowed_keys = %w(email type enabled username uid uuid)
      # explicitly set password, but only if supplied
      @user.password = params[:user]['password'] if params[:user]['password'] and !params[:user]['password'].empty? # password reset
      allowed_params = {}
      params[:user].each_pair{|key,val| allowed_params[key] = val if allowed_keys.include?(key) }
      @user.attributes = allowed_params
      if @user.save
        # create successful
        redirect_to :action => 'info', :id => @user.id
      else
        # not updated, render the form
      end
    else
      # nothing to do, render the form
    end
  end

	def wipe_confirm
		@user = User.find( params[:id] )
    # TODO: finish this
		@pagination = list_pagination
	end

	def wipe
		@user = User.find( params[:id] )
		@pagination = list_pagination
		pn = @pagination.page_number_of_item( @user )
		@user.destroy
		flash[:msg] = "User has been wiped from this database"
		redirect_to :action => 'index', :page => pn
	end

end
