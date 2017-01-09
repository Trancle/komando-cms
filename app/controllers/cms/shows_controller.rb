class Cms::ShowsController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :destroy, :create, :update_version, :create_schedule, :create_master_availability, :update_master_availability, :destroy_master_availability, :create_link_show_with_show_category, :unlink_show_from_show_category, :move_show_order_up, :move_show_order_down, :perform_preview

	def index
		list
		render :action => 'list'
	end

	def list_pagination
		self.class.list_pagination( self )
	end; protected :list_pagination

	def self.list_pagination( ct )
		CW::Pagination::Model::ActiveRecord.new( ct, "Show", Show.order_sort_order, {}, Setting['vms-protected-items-per-page'].value_typed ).add_join_accessor( 'shows.acts_as_ordered_order', Proc.new{|o| o.acts_as_ordered_order} )
	end
	def list
		# list the shows
		opts = Show.order_options
		@show_pag = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
      s.link 'add', { :action => 'new' }, {:title => 'Add a new show'}
      s.link 'add from tags', { :action => 'new', :type => 'ShowOfTag' }, {:title => 'Add a new show with episodes with common tags'}
		}.section('View') {|s|
			s.link 'jump to episode', { :controller => 'cms/episodes', :action => 'jump' }, {:title => 'Jump to an episode based on its numerical ID'}
		}
	end

	def info
		if !params[:id].to_i.eql?0
			@show = Show.find( params[:id], :readonly => true )
		else
			@show = Show.find_by_name( params[:id], :readonly => true )
		end
		@show_pag = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'title/description', { :action => 'version_dashboard', :id => @show.id }
			s.link 'settings', { :action => 'edit', :id => @show.id }
      s.link 'dynamic lead order', { :controller => '/cms/show_dl_episodes', :action => 'index', :id => @show.id }, { :title => 'Change the order episodes appear in the show\'s home page Dynamic Lead' }
			s.link 'availability schedule', { :action => 'master_availability', :id => @show.id }, { :title => 'Change when this show and all of its episodes are visible to the visitors' }
#s.link 'categories', { :controller => '/cms/show_categories', :action => 'list' }, {:title => 'List/change the categories to which this show belongs' }
			s.link 'related shows', { :controller => 'cms/related_shows', :action => 'show', :id => @show.id }, {:title => 'List/change the shows that are similar to this show' }
      s.link 'tags', {:controller => 'cms/show_tags', :action => 'list', :id => @show.id}
			s.link 'destroy', :action => 'destroy_confirm', :id => @show.id
		}.section('View') {|s|
			s.link 'preview', { :action => 'preview', :id => @show.id }, { :title => 'See this page as it would look at a time you choose' }
		}.section('Components') {|s|
			s.link 'episodes', { :controller => '/cms/episodes', :action => 'show', :id => @show.id }, {:title => 'List all the episodes in this show' }
		}
	end

	def version_dashboard
		@show = Show.find( params[:id], :readonly => true )
		@show_pag = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'edit this version', { :action => 'edit_version', :id => @show.id, :version => @show.scheduled_version_current_or_last_version_cache.version_number_cache }, { :title => 'Edit this version of the information on the left' }
		}.section( 'View' ) { |s|
			s.link 'history', { :action => 'versions', :id => @show.id }, { :title => 'View all changes made to this show' }
			s.link 'schedules', { :action => 'schedule', :id => @show.id }, { :title => 'View and edit when a specific version of this information is to appear' }
		}
	end

	def new
    case params[:type]
      when 'ShowOfTag'
        @show = ShowOfTag.new
      else
        @show = Show.new
    end
		@show_pag = list_pagination
		@show_version = ShowVersion.new
		@show_version.version_comment = 'Initial version'
	end

	def create
    case params[:type]
      when 'ShowOfTag'
        @show = ShowOfTag.new(params[:show])
      else
        @show = Show.new(params[:show])
    end
		@show_pag = list_pagination
		@show_version = ShowVersion.new( params[:show_version] )
		@show_version.editor_id = session[:user_id]

		begin
			Show.transaction do
				if @show.save
					@show_version.version_stub_id = @show.id
					flash[:msg] = "Show created"
					redirect_to :action => 'list' and return if @show_version.save!
				end
			end
		rescue
		end
		render :action => 'new' and return
	end

	def edit_version
		@show = Show.find( params[:id], :readonly => true )
		@show_pag = list_pagination
		@show_old_version = @show.version( params[:version].to_i )
		raise ActiveRecord::RecordNotFound.new if @show_old_version.nil?
		@show_version = @show_old_version.new_from
	end

	def update_version
		edit_version

		@show_version.attributes=( params[:show_version] )
		@show_version.editor_id = session[:user_id]
		@show_pag = list_pagination

		if @show_version.save
			flash[:msg] = "New version created! Version ##{@show_version.version_number_cache}"
			redirect_to :action => 'new_schedule', :id => @show.id, 'show_version[version]' => @show_version.version_number_cache and return 
		else
			render :action => 'new_schedule' and return
		end
	end

	def edit
		@show = Show.find(params[:id])
		@show_pag = list_pagination
	end
	def update
		@show = Show.find(params[:id])
		@show_pag = list_pagination
		if @show.update_attributes( params[:show] )
			flash[:msg] = "Show updated"
			redirect_to :action => 'info', :id => @show.id
		else
			render :action => 'edit'
		end
	end

	def schedule
		@show = Show.find( params[:id], :readonly => true )
		@show_pag = list_pagination
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, "ShowVersionScheduleDate", CW::SortOrder.desc('show_version_schedule_dates.start_at'), { :conditions => ['show_version_schedule_dates.exclusivity_id = ?',@show.id] }, Setting['vms-protected-items-per-page'].value_typed, 'page', %w(show_version_schedule_dates.start_at) )
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'add/overlap', { :action => 'new_schedule', :id => @show.id }, {:title => 'Schedule when a new version will appear'}
		}
	end

	def new_schedule
		@show = Show.find( params[:id], :readonly => true )
		@show_pag = list_pagination
		@show_version_schedule_date = ShowVersionScheduleDate.new
		@show_version_schedule_date.start_at = Time.now
		@show_version_schedule_date.end_at = @show_version_schedule_date.start_at + 2.weeks
	end

	def create_schedule
		@show = Show.find( params[:id] )
		@show_pag = list_pagination
		svsd = params[:show_version_schedule_date]
		@show_version_schedule_date = ShowVersionScheduleDate.new( svsd )
		# required before we go to the scheduling: otherwise, the nils will not be propagated.
		@show_version_schedule_date.enforce_nil_start_end
		@show_version = @show.version( params[:show_version][:version].to_i )
		if @show_version.nil?
			render :action => 'schedule'
		end

		if @show.scheduled_version_schedule_version_with_range( @show_version, @show_version_schedule_date )
			redirect_to :action => 'schedule', :id => @show.id
		else
			render :action => 'new_schedule'
		end
	end

	def versions
		@show = Show.find( params[:id] )
		@show_pag = list_pagination
		@show_version_pag = CW::Pagination::Model::ActiveRecord.new( self, "ShowVersion", CW::SortOrder.desc('id'), { :conditions => ['version_stub_id = ?',@show.id] }, Setting['vms-protected-items-per-page'].value_typed )
	end

	def destroy_confirm
		@show = Show.find( params[:id], :readonly => true )
		@show_pag = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.button 'destroy', { :action => 'destroy', :id => @show.id }, {:class => 'button'}
		}
	end

	def destroy
		@show = Show.find( params[:id] )
		@show_pag = list_pagination
		@show.destroy
		flash[:msg] = "Show destroyed"
		redirect_to :action => 'list'
	end




	def master_availability
		@show = Show.find( params[:id] )
		@show_pag = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'add', { :action => 'new_master_availability', :id => @show.id }, { :title => 'Add a range of time between which this show will be visible' }
		}
		@availabilities = @show.show_publish_dates
	end

	def new_master_availability
		@show = Show.find( params[:id] )
		@show_pag = list_pagination
		@availability = ShowPublishDate.new
		@availability.start_at = Time.now
		@availability.end_at = @availability.start_at + 3.month
	end

	def create_master_availability
		@show = Show.find( params[:id] )
		@show_pag = list_pagination
		@availability = ShowPublishDate.new( params[:availability] )
		@availability.enforce_nil_start_end
		@availability.exclusivity_id = @show.id
		if @availability.save
			flash[:msg] = "Master Availability created"
			redirect_to :action => 'master_availability', :id => @show.id
		else
			render :action => 'new_master_availability'
		end
	end

	def edit_master_availability
		@availability = ShowPublishDate.find( params[:id] )
		@show = @availability.show
		@show_pag = list_pagination
	end

	def update_master_availability
		@availability = ShowPublishDate.find( params[:id] )
		@show = @availability.show
		@show_pag = list_pagination
		if @availability.update_attributes( params[:availability] )
			flash[:msg] = "Master Availability updated"
			redirect_to :action => 'master_availability', :id => @availability.show.id
		else
			render :action => 'edit_master_availability'
		end
	end

	def destroy_master_availability_confirm
		@availability = ShowPublishDate.find( params[:id] )
		@show = @availability.show
		@show_pag = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.button 'destroy', { :action => 'destroy_master_availability', :id => @availability.id }, {:class => 'button'}
		}
	end

	def destroy_master_availability
		@availability = ShowPublishDate.find( params[:id] )
		@show = @availability.show
		@show_pag = list_pagination
		@availability.destroy
		redirect_to :action => 'master_availability', :id => @availability.show.id
	end


=begin
Deprecated until this is added back into the software later. Should still work.
	def new_link_show_with_show_category
		@show = Show.find params[:id]
		@show_pag = list_pagination
		@link = LinkShowWithShowCategory.new
	end

	def create_link_show_with_show_category
		@show = Show.find params[:id]
		@show_pag = list_pagination
		@link = LinkShowWithShowCategory.new params[:link]
		@link.categorizeable_id = @show.id
		if @link.save
			flash[:msg] = 'Show linked with category'
			redirect_to :action => 'info', :id => @show.id
		else
			render :action => 'new_link_show_with_show_category'
		end
	end

	def unlink_show_from_show_category
		@link = LinkShowWithShowCategory.find params[:id]
		@link.destroy
		flash[:msg] = 'Show unlinked from category'
		redirect_to :action => 'info', :id => @link.categorizeable_id
	end
=end

	def move_show_order_up
		@show = Show.find params[:id]
		@show_pag = list_pagination
		@show.move_order_up
		flash[:msg] = 'Show moved up'
		redirect_to :action => 'index'
	end

	def move_show_order_down
		@show = Show.find params[:id]
		@show_pag = list_pagination
		@show.move_order_down
		flash[:msg] = 'Show moved up'
		redirect_to :action => 'index'
	end


	def preview
		@show = Show.find( params[:id] )
		@show_pag = list_pagination
	end

	def perform_preview
		@show = Show.find( params[:id] )
		@show_pag = list_pagination
		@preview_time = CW::StandAloneTimeHelper.new( params[:preview_time].merge( :z => 'local' ) )
		pt = @preview_time.t.utc

		if @show.scheduled_version_current( pt ).nil?
			flash[:msg] = "That show has no current version, please schedule one during your desired preview time"
			redirect_to( :action => 'versions', :id => @show.id ) and return
		else
			theurl = url_to_show( @show.scheduled_version_current_or_last_version )
			theurl[:controller] = '/' + theurl[:controller]
			redirect_to( theurl.merge( :admin_previw_at_time => pt.to_i ) )
		end
  end


  def tags
    @show = Show.find( params[:id] )
    if request.get?
      # list tags
    elsif request.post?
      @show.taggin
    elsif request.delete?
    end
    @tags = @show.tags
  end

end
