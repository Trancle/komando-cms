class AuthController < ApplicationController
	layout 'auth'

	skip_filter :require_login
	skip_filter :require_administrator_user

	# never cache any login stuff
	skip_filter :default_caching_policy

	hide_action :create_first_login, :get_and_update_login, :create_layout, :login_common, :render_emergency_login, :disable_cache, :post_login, :post_cas_session_setup
	before_filter :enable_admin_layout_preview, :only => 'cannot'
	before_filter :enable_admin_preview_at_time, :only => 'cannot'

	# Remove passwords from logs
	filter_parameter_logging :password

	# If they enter a bad URL, respond with the index page

	before_filter :disable_cache

  before_filter CASClient::Frameworks::Rails::Filter, :only => :cas_authenticate

	def index
		login_common
		create_layout
		begin
			render :action => 'index'
		rescue StandardError => s
			redirect_to :action => 'emergency_login', :r => @r
		end
	end

	require_post_method_for :login

	def login
		login_common
    # ensure the response of logging in is never cached
    # Don't want to cache the cookie or the page the person is redirected to
    override_expires_in 1.minutes, :public => false

		authn = nil
		authz = nil
    @is_authenticated = false
		begin
			authn = CwAuthenticationManager.authentication_mechanism.new( :username => @username, :password => params[:password] )
			authz = CwAuthorizationManager.authorization_mechanism.new( @username )
			# special method to allow the authorization mechanism to piggy-back off of the authentication mechanism (saves a query)
			authz.authentication_mechanism= ( authn ) if authz.respond_to?(:authentication_mechanism=)

      @is_authenticated = authn.is_authenticated?
		rescue StandardError => s
			if authn.nil?
				Rails.logger.error( "Authentication/Authorization failure: unable to create the driver for the authorization" )
			else
				Rails.logger.error( "Authentication/Authorization failure (programmatic error) for username: '#{@username}'\nAuthn Diagnostic:\n#{authn.problem_diagnostic_string}" )
				Rails.logger.error( s.message + "\n" + s.backtrace.join("\n") )
			end
			@user = UserAnonymous.new
			cannot
			redirect_to :action => 'cannot' and return
		end

		u = nil
		if @is_authenticated
			# grab the user
			begin
				u = User.find_by_uid( authn.uid )
				if u.nil?
					u = create_first_login( authn, ( ( authz.can_access_backoffice? ) ? ( UserAdministrator ) : ( UserPremium ) ) )
				else
					u = get_and_update_login( authn, ( ( authz.can_access_backoffice? ) ? ( UserAdministrator ) : ( UserPremium ) ) )
				end
			rescue
				# this indicates an error updating the user. Catch this and allow custom message to address account issues
				Rails.logger.error( "User create/update failure for username: '#{@username}'\nAuthn Diagnostic:\n#{authn.problem_diagnostic_string}" )
				@user = u
				cannot
				render :action => 'cannot' and return
			end
		end


      post_login
  end


  def post_login
    if @remember_me
      # asked to be remembered, use the default settings in the site configuration
      if Setting['vms-protected-remember-me-days'].value_typed.eql?0
        # 1 year as INFINITY
        session[:expires] = Time.now.utc + 1.year
      else
        session[:expires] = Time.now.utc + Setting['vms-protected-remember-me-days'].value_typed.days if Setting
      end
    else
      # did NOT ask to be remembered, simply store the cookie for 8 hours (like Kerberos defaults)
      session[:expires] = Time.now.utc + 1.day
    end
#request.session_options= { :expires_after => session[:expires] }

    if @is_authenticated
  # save the session
      session[:user_id] = @user.id
      session[:last_ip] = request.remote_ip
      session[:last_access] = Time.now.utc

      # Login successful, redirect them back to where they came from or the home page if nothing specified
      respond_to do |format|
        format.html do
          if @r.empty?
            redirect_to '/'
          else
            redirect_to sanitize_url( @r )
          end
        end
  # JSON will not redirect, instead, we'll respond with success/JSON
        format.json do
          render :json => '{ did_login: true }'
        end
      end



    else
      respond_to do |format|
        format.html do
          @error_message = 'Your username or password is not correct'
          if @use_emergency_login
            render_emergency_login and return
          else
            create_layout
            render :action => 'index'
          end
        end
  # JSON will report the failure
        format.json do
          render :json => '{ did_login: false }'
        end
      end
    end
  end


  # before auth
  def cas_authenticate
    # this is just a redirect. Send them off to CAS
    post_cas_session_setup
    redirect_to sanitize_url( params[:r] )
  end

  def admin
    @login_action = 'admin'
    login_common
    if request.get?
    else # post request
      # by-passes the locally configured authentication and goes to the main admin authentication
      @user = User.authenticate_admin_user( params[:username], params[:password] )
      @is_authenticated = !@user.nil?
      post_login
    end
  end

	def logout
		reset_session
		respond_to do |format|
			# for HTML: redirect to home page
			format.html { redirect_to '/' }
		end
	end

	def	cannot
		@user = UserAnonymous.new if @user.nil?
		@time = Time.now.utc if @time.nil?
		@page_layout = ( @layout_override || PageLayout.first( :conditions => "programmatic_name = 'auth-cannot-page'" ).scheduled_version_current( @time ) )
		@layout = @page_layout.layout
	end



	def create_first_login( authn, type )
		u = type.new( :username => authn.username, :last_login_timestamp => Time.now.utc, :uid => authn.uid, :email => authn.email )
		u.save!
		u
	end

	def get_and_update_login( authn, type )
		u = User.find_by_uid( authn.uid )
		typechanged = false
		typechanged = true unless type.name.eql?u.class.name

# update the information
		u.username = authn.username
		u.last_login_timestamp = Time.now.utc
		u.email = authn.email
		u.type = type.name
		u.save!

		u = User.find_by_uid( authn.uid ) if typechanged
		u		
	end

# This is just for testing to be sure that exceptons are still handled
#def rescue_action_locally(e); rescue_action_in_public(e); end

	def rescue_action_in_public( e )
		if e.is_a?(ActionController::UnknownAction)
			# We're going to redirect them to the index
			redirect_to( :action => 'index' ) and return
		else
			# Use the application controller's handler
			super(e)
		end
	end


	# We need an emergency login form for when a mistake is made and the layout is broken. It will be logically equivalent to the
	# dynamic login, however, will not include any dynamic layout
	def emergency_login
		login_common
		@use_emergency_login = true
		# render the emergency_login view, no layout
		render_emergency_login and return
	end


	protected
	def create_layout
		@layout = ( @layout_override || PageLayout.find( :first, :conditions => "programmatic_name = 'auth-index-page'" ).scheduled_version_current( @time || Time.now.utc ) ).layout
	end

	def login_common
		@user = User.new
		@username = params[:username] || ''
    @login_action = 'login'
		# never grab the password and re-display
		@password = ''
		@remember_me = params[:remember_me]
		@use_emergency_login = !params[:use_emergency_login].nil? # true if it exists, false if not
		if params[:r].nil? or params[:r].empty?
			@r = ''
		else
			@r = sanitize_url( params[:r] )
		end
	end

	def render_emergency_login
		render :action => 'emergency_login', :layout => false
	end

	def disable_cache
		expires_now
	end
end
