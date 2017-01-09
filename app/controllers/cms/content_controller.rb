class Cms::ContentController < CmsController
	layout 'admin'
	helper :watch
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time
	before_filter :list_pagination

	require_post_method_for :destroy, :destroy_content, :update, :create, :configure_embedded_on_demand, :configure_hosted_live, :configure_hosted_on_demand, :update_video_content

# used in production
	def index
		list
	end

# used in production
	def list_pagination
    per_page = params[:per_page] || Setting['vms-protected-items-per-page'].value_typed
    per_page = per_page.to_i
    per_page = 100 if per_page > 100
		@mfrn_pag = CW::Pagination::Model::ActiveRecord.new( self, 'VideoContentName', CW::SortOrder.desc('created_at').asc('pretty_name'), {}, per_page )
	end
	protected :list_pagination

	def list
		if params[:id]
			@filter_by_type = 'Showing only ' + params[:id].underscore.humanize
		else
			@filter_by_type = 'All'
		end
    per_page = params[:per_page] || Setting['vms-protected-items-per-page'].value_typed
    per_page = per_page.to_i
    per_page = 100 if per_page > 100
		@video_content_type_limited = params[:id]
		if @video_content_type_limited and VideoContent.is_valid_sub_subclass?( @video_content_type_limited )
			@mfrn_pag = CW::Pagination::Model::ActiveRecord.new( self, 'VideoContentName', CW::SortOrder.desc('created_at').asc('pretty_name'), {:conditions => ['EXISTS ( SELECT * FROM video_contents WHERE video_contents.pretty_name_id = video_content_names.id AND video_contents.type = ?)',@video_content_type_limited]}, per_page )
		end

		respond_to do |format|
			format.json { render :json => '{"items": [' + @mfrn_pag.items_for_current_page.collect{|x| x.to_json}.join(',') + '], "total_number_of_pages": ' + (@mfrn_pag.count_pages).to_s + ', "total_number_of_items": ' + @mfrn_pag.count_items.to_s + ' }' and return true }
			format.html {
				@action_nav = CW::ActionNav::Controller::Base.new.section( 'Change' ) {|s|
					s.link 'add', { :action => 'new' }, { :title => 'Add video content to the site' }
				}.section('View') {|s|
					s.link 'filter by type', { :action => 'filter_by' }, { :title => 'Show only certain types of content' }
				}
				render :action => 'list' and return
			}
		end
	end

# used in production
	def info
		@mfrn = VideoContentName.find( params[:id], :readonly => true )
		@check_exists_at_cdn = true if params[:check_exists_at_cdn]
		video_content_type = nil
		video_content_type = @mfrn.video_contents.first.class.name unless @mfrn.video_contents.empty?
		@action_nav = CW::ActionNav::Controller::Base.new.section( 'Change' ) {|s|
			s.link 'add format', { :action => 'add_video', :id => @mfrn.id, :video_content_type => video_content_type }, { :title => 'Add a video in a different format to this video content' }
			s.link 'rename', { :action => 'edit', :id => @mfrn.id }, {:title => 'Change the name of this video content'}
			s.link 'destroy', { :action => 'confirm_destroy', :id => @mfrn.id }, { :title => 'Destroys this video content and all formats contained within' }
		}
	end


	def video_content_info
		@mfr = VideoContent.find( params[:id], :readonly => true )
		@mfrn = @mfr.pretty_name
		@check_exists_at_cdn = true if params[:check_exists_at_cdn]
		video_content_type = nil
		video_content_type = @mfrn.video_contents.first.class.name unless @mfrn.video_contents.empty?
		@action_nav = CW::ActionNav::Controller::Base.new.section( 'Change' ) {|s|
			s.link 'edit', { :action => 'edit_video_content', :id => @mfr.id }, { :title => 'Reconfigure this format' }
			s.button 'destroy', { :action => 'confirm_destroy_content', :id => @mfr.id }, { :title => 'Destroys this one video content format', :class => 'button' }
		}
	end

# used in production
	def check_exists_at_cdn
		@mfr = VideoContent.find( params[:id] )
		begin
			if @mfr.exists_at_cdn?
				render :inline => '<span class="ok">yes</span>', :layout => false
			else
				render :inline => '<span class="warning">no</span>', :layout => false
			end
		rescue StandardError => e
			# Prevents the page from breaking, but we should send an error anyway
			#rescue_action_in_public e
			render :inline => '<span class="warning">An error occurred while looking up the content. This means that there is a misconfiguration with your hosting provider information, or VMS is now disconnected from your hosting provider. The error was:</span><pre>' + ERB::Util.html_escape(e.message + "\n\n" + e.backtrace.join("\n")) + '</pre>'
		end
	end

# used in production
# These are new managed File resource names, not content
	def new
		@mfrn = VideoContentName.new
	end

# used in production
	def create
		@mfrn = VideoContentName.new( params[:mfrn] )
		@mfrn.uploader_user_id = session[:user_id]
		@video_content_type = params[:video_content_type]
		if @mfrn.save
			redirect_to :action => 'add_video', :id => @mfrn.id
		else
			render :action => 'new'
		end
	end




# used in production
	def add_video
		@mfrn = VideoContentName.find( params[:id] )

		# When adding content and some content already exists, it must be of the same elemental type: embedded, hosted live, or hosted on demand. You can't mix and match because it doesn't make sense to mix and match
		unless @mfrn.video_contents.empty?
			match_against = @mfrn.video_contents.first
			if match_against.is_a?( VideoContentEmbeddedOnDemand )
				redirect_to :action => 'add_video_content_embedded_on_demand', :id => params[:id]
			elsif match_against.is_a?( VideoContentHostedOnDemand )
				redirect_to :action => 'add_video_content_hosted_on_demand', :id => params[:id]
			elsif match_against.is_a?( VideoContentHostedLive )
				redirect_to :action => 'add_video_content_hosted_live', :id => params[:id]
			else
				raise "Video Content type is unknown. This is impossible?"
			end
		end
	end

# used in production
	def add_video_content_hosted_on_demand
		@mfrn = VideoContentName.find params[:id]
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'VideoContentHostingProvider', CW::SortOrder.asc('name'), {:conditions => "type LIKE 'VideoContentHostingProviderOnDemand%' AND NOT deprecated"}, Setting['vms-protected-items-per-page'].value_typed )
		case @pagination.count_items
			when 1
				redirect_to :action => 'new_video_content_hosted_on_demand', :id => @mfrn.id, :video_content_hosting_provider_id => @pagination.first_item_of_all.id
			when 0
				# none to chose from... Not sure what to do here. Render empty picker page
			else
				# render picker page
		end
	end

# used in production
	def add_video_content_embedded_on_demand
		@mfrn = VideoContentName.find params[:id]
	end

# used in production
	def add_video_content_hosted_live
		@mfrn = VideoContentName.find params[:id]

    @pagination = CW::Pagination::Model::ActiveRecord.new( self, 'VideoContentHostingProvider', CW::SortOrder.asc('name'), {:conditions => "type LIKE 'VideoContentHostingProviderLive%' AND NOT deprecated"}, Setting['vms-protected-items-per-page'].value_typed )
		case @pagination.count_items
			when 1
				redirect_to :action => 'new_video_content_hosted_live', :id => @mfrn.id, :video_content_hosting_provider_id => @pagination.first_item_of_all.id
			when 0
				# none to chose from... Not sure what to do here. Render empty picker page
			else
				# render picker page
		end
	end

# used in production
	def new_video_content_embedded_on_demand
		@mfrn = VideoContentName.find params[:id]

		@video_content_type = params[:video_content_type]
		# can't let users create their own classes now can we? :-)
		if VideoContentEmbeddedOnDemand.is_valid_subclass?(@video_content_type)
# valid subclass
			@mfr = @video_content_type.constantize.new
			render :action => 'embedded_on_demand/new'
		else
			flash[:msg] = 'Invalid Embedding type chosen. Please pick a valid embedding type.'
			redirect_to :action => 'add_video_content_embedded_on_demand', :id => @mfrn.id
		end
	end

# used in production
	def create_video_content_embedded_on_demand
		@mfrn = VideoContentName.find params[:id]


		# can't let users create their own classes now can we? :-)
		if VideoContentEmbeddedOnDemand.is_valid_subclass?(params[:mfr][:type])
# valid subclass
			@mfr = params[:mfr][:type].constantize.new( params[:mfr] )
			# Security: force over-ride
			@mfr.uploader_user_id = session_user.id
			@mfr.pretty_name_id = @mfrn.id
			@mfr.video_content_hosting_provider_id = nil
			@mfr.bitrate = 0
			@mfr.file_size = 0.0

			if !@mfrn.video_contents.empty? and !@mfrn.video_contents.to_a.detect{|vc| vc.is_a?(VideoContentEmbeddedOnDemand)}
				@mfr.errors.add[:base] << "Embedded on Demand content is not allowed to be associated with this content that contains other content that is not also Embedded on Demand"
				render :action => 'embedded_on_demand/new' and return
			else
				if @mfr.save
					flash[:msg] = "Embedded video added"
					redirect_to :action => 'info', :id => @mfrn.id
				else
					render :action => 'embedded_on_demand/new'
				end
			end
		else
			flash[:msg] = 'Invalid Embedding type chosen. Please pick a valid embedding type.'
			redirect_to :action => 'add_video_content_embedded_on_demand', :id => @mfrn.id
		end
	end


# used in production
	def new_video_content_hosted_on_demand
		@mfrn = VideoContentName.find params[:id]
		@provider = VideoContentHostingProvider.find params[:video_content_hosting_provider_id]

	# can't let users create their own classes now can we? :-)
# valid subclass
		@mfr = @provider.content_model_name.constantize.new
		@mfr.video_content_hosting_provider_id = @provider.id
		render :action => 'hosted_on_demand/new'
	end

# used in production
	def create_video_content_hosted_on_demand
		@mfrn = VideoContentName.find params[:id]
		@provider = VideoContentHostingProvider.find params['mfr']['video_content_hosting_provider_id']

		@mfr = @provider.content_model_name.constantize.new( params['mfr'].reject{|p,v| p.eql?'file_path' } )
		@mfr.video_content_hosting_provider_id = @provider.id
		@mfr.uploader_user_id = session[:user_id]
		@mfr.pretty_name_id = @mfrn.id

		# disallow adding content of a different type
		if !@mfrn.video_contents.empty? and !@mfrn.video_contents.to_a.detect{|vc| vc.is_a?(VideoContentHostedOnDemand)}
			@mfr.errors.add[:base] << "Hosted on Demand content is not allowed to be associated with this content that contains other content that is not also Hosted on Demand"
			render :action => 'hosted_on_demand/new' and return
		else
			unless params['mfr']['file_path'].nil?
				if @mfr.upload_mfrn( params['mfr'] ) and @mfr.errors.empty?
					@mfr.uploader_user_id = session[:user_id]
					@mfr.pretty_name_id = @mfrn.id
					@mfr.video_content_hosting_provider_id = @provider.id # set again for safety
					# uploads to VMS
					if @mfr.upload_and_save
						redirect_to :action => 'info', :id => @mfrn.id and return
					else
						render :action => 'hosted_on_demand/new' and return
					end
				else
					render :action => 'hosted_on_demand/new' and return
				end
			else
				# no file uploaded
				render :action => 'hosted_on_demand/new' and return
			end
		end
	end


# used in production
	def new_video_content_hosted_live
		@mfrn = VideoContentName.find params[:id]
		@provider = VideoContentHostingProvider.find params[:video_content_hosting_provider_id]

	# can't let users create their own classes now can we? :-)
# valid subclass
		@mfr = @provider.content_model_name.constantize.new
		@mfr.video_content_hosting_provider = @provider
		render :action => 'hosted_live/new'
	end

	def configure_type_hosted_live
		@mfrn = VideoContentName.find params[:id]
		@mfr.video_content_hosting_provider_id = @provider.id

		# can't let users create their own classes now can we? :-)
		if VideoContentHostedLive.is_valid_subclass?(@video_content_type)
# valid subclass
			@mfr = @video_content_type.constantize.new
			render :action => 'hosted_live/' + VideoContent.sub_subclass_name(@mfr).underscore
		else
			render :action => 'configure_type_hosted_live'
		end
	end


	def create_video_content_hosted_live
		@mfrn = VideoContentName.find params[:id]
		@provider = VideoContentHostingProvider.find params['mfr']['video_content_hosting_provider_id']

		@mfr = @provider.content_model_name.constantize.new( params['mfr'] )
		@mfr.video_content_hosting_provider_id = @provider.id
		@mfr.uploader_user_id = session[:user_id]
		@mfr.pretty_name_id = @mfrn.id
		@mfr.file_size = 0
		if !@mfrn.video_contents.empty? and !@mfrn.video_contents.to_a.detect{|vc| vc.is_a?(VideoContentHostedLive)}
			@mfr.errors.add[:base] << "Hosted Live content is not allowed to be associated with this content that contains other content that is not also Hosted Live"
			render :action => 'hosted_live/new' and return
		else
			if @mfr.save
				redirect_to :action => 'info', :id => @mfrn.id and return
			else
				render :action => 'hosted_live/new' and return
			end
		end
	end




# Destroys the Content Name
	def destroy
		@mfrn = VideoContentName.find params[:id]

		if @mfrn.destroy
:wa
			flash[:msg] = "Video Content Name & Content Destroyed"
			redirect_to :action => 'index'
		else
# FIXME: Need some sort of message here explaining why deletion did not occur
			render :action => 'confirm_destroy'
		end
	end

# This is the Video conent container destruction
	def confirm_destroy
		@mfrn = VideoContentName.find params[:id]
	end

# Destroys content that's part of a content name
	def destroy_content
		@mfr = VideoContent.find params[:id]
		@mfrn = @mfr.pretty_name
		if @mfr.destroy
			flash[:msg] = "Video Content Destroyed"
			redirect_to :action => 'info', :id => @mfrn.id
		else
# FIXME: Need some sort of message here explaining why deletion did not occur
			redirect_to :action => 'info', :id => @mfrn.id
#render :action => 'confirm_destroy_content'
		end
	end

# This is the Format destruction
	def confirm_destroy_content
		@mfr = VideoContent.find params[:id]
		@mfrn = @mfr.pretty_name
	end

	def edit
		@mfrn = VideoContentName.find( params[:id] )
	end

	def update
		@mfrn = VideoContentName.find params[:id]

		VideoContentName.transaction do
			if @mfrn.update_attributes( params[:mfrn] )
				redirect_to :action => 'index'
			else
				render :action => 'edit'
			end
		end
	end


	def edit_video_content
		@mfr = VideoContent.find params[:id]
		@mfrn = @mfr.pretty_name
	end

	def update_video_content
		@mfr = VideoContent.find params[:id]
		@mfrn = @mfr.pretty_name
		if @mfr.update_attributes(params[:mfr])
			redirect_to :action => 'video_content_info', :id => @mfr.id
		else
			render :action => 'edit_video_content'
		end
	end


# Very likely deprecated. Used to be used in the window_picker, but this was supplanted by adding items to the json response of list.json
	def count
		thecount = VideoContentName.count
		respond_to do |format|
			format.json { render :json => "{count: #{thecount}}" }
		end
	end


	# Allows users to filter content by type
	def filter_by
		@type_pag = CW::Pagination::Model::ActiveRecord.new( self, 'VideoContent', CW::SortOrder.asc('type'), {:distinct => 'type'}, Setting['vms-protected-items-per-page'].value_typed, 'page' )
		@type_pag.add_join_accessor 'type', Proc.new{|o| o.type}
	end




# Unfinished: untested
	def upload_video_content_hosted_on_demand
		js_name_reg = /\A[a-z_][a-z0-9_]*\Z/i
		@js_object_name = params[:js_object_name]

		# sanitization: only allow variable names: no special JS injection
		# If invalid, replace with generic name
		@js_object_name = 'uploader' if ( @js_object_name =~ js_name_reg ).nil?


		# We'll just be uploading content
		@mfrn = VideoContentName.find params[:id]
		@video_content_type = params[:video_content_type]

		# Sanitize the class
		unless VideoContentHostedOnDemand.is_valid_subclass?(@video_content_type)
			@video_content_type = 'VideoContentHostedOnDemandLimelightCoreStorage'
		end

		@mfr = @video_content_type.constantize.new( params['mfr'].reject{|p,v| p.eql?'file_path' } )

		@mfr.uploader_user_id = session[:user_id]
		@mfr.pretty_name_id = @mfrn.id
		@mfr.configuration_complete = false
		# skips validation for extra, non-upload fields
		@mfr.set_new_upload_only


		unless params[:mfr][:original_filename].nil?
			if @mfr.upload_mfrn( params[:mfr] ) and @mfr.errors.empty?
				@mfr.uploader_user_id = session[:user_id]
				@mfr.pretty_name_id = @mfrn.id
				@mfr.video_content_hosting_provider_id = @provider.id # set again for safety
				if @mfr.save
					render :inline => "#{@js_object_name}.success(null);", :layout => 'html_javascript_response'
				else
					render :inline => "#{@js_object_name}.failed(#{@mfr.errors.to_json});", :layout => 'html_javascript_response' and return
				end
			else
				render :inline => "#{@js_object_name}.failed(#{@mfr.errors.to_json});", :layout => 'html_javascript_response' and return
			end
		else
			# no file uploaded
			render :inline => "#{@js_object_name}.failed([[\"base\",\"Please specify a file\"]]);", :layout => 'html_javascript_response' and return
		end
	end

end
