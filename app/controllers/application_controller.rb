# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'uri'
require 'timeout'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
	# See ActionController::RequestForgeryProtection for details
  protect_from_forgery
	helper CW::BreadCrumbs::ViewHelper

	# Hide these magic actions
	hide_action :session_user, :sanitize_url, :is_logged_in?, :require_login, :cacheable_cache, :cacheable_clear_cache, :require_administrator_user, :rescue_action_in_public, :rescue_action_locally, :render_error_403, :enable_admin_layout_preview, :enable_admin_preview_at_time, :generate_global_utc_time, :satisfy_require_administrator_user?, :default_caching_policy, :override_expires_in, :post_cas_session_setup
# Disabled request logging
#:request_log_log_request_with_user_id, :request_log, :request_log=, :request_log_log_request, 

	before_filter :generate_global_utc_time
	before_filter :require_login
	before_filter :require_administrator_user

	# lets us preview
	before_filter :enable_admin_layout_preview
	before_filter :enable_admin_preview_at_time

	# caching
	before_filter :default_caching_policy



#def self.request_log_klass; 'RequestLog'.constantize; end
#include CW::RequestLog::ActionController
	include CW::ActsAs::Cacheable

	# disable logging globally, it's a big burden
	#before_filter :request_log_log_request_with_user_id
#def request_log_log_request_with_user_id
#		request_log_log_request do |l|
#			l.user_id_or_nil = session[:user_id] # put the session user_id in here!
#		end
#	end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password



	def is_logged_in?
		# does the session have a user_id? If not, no session
		if session and !session[:user_id].nil?
        if session[:expires]
          # Check expiration time.
          session[:expires].to_time > Time.now.utc
        else
          # No session expiry: BAD COOKIE!
          false
        end
		else
      # Check session expiration, if none: assume expired
      if session[:mem_exp]
        session[:mem_exp].to_time > Time.now.utc
      else
        # No user id: BAD COOKIE! or NO COOKIE!
        false
      end
		end
  end

	# all users have some sort of user class/model. Even unauthenticated ones.
	def session_user
		# gets the user
		cacheable_cache( :session_user ) do
			if is_logged_in?
				# look up the user, the user's type will be automatically generated
				begin
				User.find( session[:user_id] )
				rescue ActiveRecord::RecordNotFound => s
					# if user was deleted from database: force re-login
					UserAnonymous.new
				end
			else
				# no session: this is an anonymous user
				UserAnonymous.new
			end
		end
	end

	# ensures that none of our redirect requests fall off the site (hack attempts)
	def sanitize_url( ur )
		begin
			u = URI.parse( ur )
			return ur if u.host.nil?
			h = URI.parse( request.url() )
			return h.scheme + '://' + h.host + (( h.port.nil? ) ? ( '' ) : ( ':' + h.port.to_s ) ) unless u.host.eql?h.host
			ur
		rescue URI::InvalidURIError => s
			request.url
		end
	end

	def require_login
		if is_logged_in?
			true
		else
			# redirect to login
      unless AdministrationVisibilityConfig.visible?
			  redirect_to( url_for(:controller => "/auth", :r => self.request.url) ) and return false
      else
        # admin enabled. Redirect to admin-specific login
        redirect_to( url_for(:controller => "/auth", :action => 'admin', :r => self.request.url) ) and return false
      end
		end
	end


	def require_administrator_user
		# if administrator visibility is disabled, always deny the page
		unless AdministrationVisibilityConfig.visible?
			render_error_403 and return false
		end
		if satisfy_require_administrator_user?
			true
		else
			render_error_403 and return false
		end
	end

	def satisfy_require_administrator_user?
		session_user.is_a?UserAdministrator
	end

	def render_error_403
		render :file => ('public/403.html').to_s, :status => 403, :layout => false
	end

# uncomment this to tell the development environment to fire off e-mail messages. Good for testing
#def rescue_action_locally(exception); rescue_action_in_public( exception ); end

	def rescue_action_in_public(exception)
		case exception.class.name
			when 'ActionController::InvalidAuthenticityToken'
				# ignore: this means they clicked the form button twice
			else
				begin
					p = params.dup
					p[:password] = '[FILTERED]' if p[:password] # remove password to prevent confidential information breach
					p[:authenticity_token] = '[FILTERED]' if p[:authenticity_token] # remove password to prevent confidential information breach

					# Only try to send error messages for 30 seconds, then pull back and resume work.
					begin
						Timeout::timeout(30) do
							ExceptionNotification.deliver_exception_notification( exception, request.request_uri, request.path_parameters['controller'], p, {'IP Address' => request.remote_ip, 'User Agent' => request.headers['User-Agent'] } ) if ExceptionNotificationConfiguration.conf[:enabled]
						end
					rescue Timeout::Error => s
						# do nothing: this prevents the MAILER from stalling the application when sends fail temporarily
					end
				rescue StandardError => s
					# do nothing: this prevents the MAILER from blowing up the application
				end
		end

		super
	end




	def self.require_post_method_for( *args )
		verify :method => :post, :only => args, :render => { :file => RAILS_ROOT + '/public/405.html', :status => 405 }
	end


	def enable_admin_layout_preview
		if params[:admin_page_layout_preview_version_id]
			if satisfy_require_administrator_user?
				conds = ['programmatic_name = ?',self.controller_name + '-' + self.action_name + '-page']
				begin
				@layout_override = PageLayout.find( :first, { :conditions => conds } ).version( params[:admin_page_layout_preview_version_id].to_i )
				rescue StandardError => s
					# if cannot lookup, ignore
				end
				true
			else
				# ignore the time
				false
			end
		else
			true
		end
	end
	
	def enable_admin_preview_at_time
		if params[:admin_preview_at_time]
			if satisfy_require_administrator_user?
				t = Time.now.utc
				t = t - t.to_i
				@time = t + params[:admin_preview_at_time].to_i
			else
				#ignore the setting
				@time = Time.now.utc
				true
			end
		else
			@time = Time.now.utc
			true
		end
	end

	def generate_global_utc_time
		@time = Time.now.utc
	end


	def user_agent_info
		UserAgent.new( request.headers["User-Agent"] ) unless request.headers.has_key?("User-Agent")
	end


	def default_caching_policy
    response.headers["Vary"] = 'Accept-Encoding'
		if is_logged_in?
			expires_in 0, :public => false, 'must-revalidate' => true
		else
			expires_in 5.minutes, :public => true
		end
	end

  def override_expires_in( relative_seconds, opts = {} )
    response.headers["Cache-Control"] = ""
    expires_in relative_seconds, opts
  end





  def post_cas_session_setup
    # If they're here, that means they went to cas (see filter above: CASClient::Frameworks::Rails::Filter)
    # and were authenticated. There's no way the could be here if that were not the case.
    # we should have the cas login name:
    login_name = session[:cas_user]
    if login_name
      # get the uuid
      begin
        session[:mem_lvl] = '' # no level
        user = KOMAPI.get_user_by_email( login_name )
        if user
          session[:display_name] = KOMAPI.get_username( user['uuid'] ) || begin; KOMAPI.user_get( user['uuid'], 'first_name' ); rescue; nil; end || login_name

          # This will return a 404 if they're no longer a member
          exp = KOMAPI.membership_level_for_user_uuid( user['uuid'] )
          session[:mem_exp] = Time.at(exp['expires_at'] || 0)
          e = Time.now + 30.days
          session[:expires] = e
          session[:expires] = Time.at(exp['expires_at']) if exp['expires_at'] and e > Time.at(exp['expires_at'])
          session[:mem_lvl] = exp['level'] || ''
        end
      rescue KomApi::SendError => e
        # There was a problem contacting the server, don't set a user membership level. They might not even have a membership
        # just leave them as they are
      end
    end
  end


	class StopTransactionError < StandardError
	end


end
