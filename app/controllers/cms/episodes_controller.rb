class Cms::EpisodesController < ApplicationController
	include ShowsHelper
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	def index
		show
		render :action => 'show'
	end

require_post_method_for :create, :update, :update_version, :destroy, :create_schedule, :create_master_availability, :update_master_availability, :destroy_master_availability, :create_free_availability, :update_free_availability, :destroy_free_availability

# Shows you things in the show
	def episode_show_pagination
		self.class.episode_show_pagination( self, @show )
	end
	protected :episode_show_pagination

	def self.episode_show_pagination( ct, show )
		CW::Pagination::Model::ActiveRecord.new( ct, "Episode", Episode.order_sort_order.invert, Episode.find_episodes_for_show_options(show.id,{},show), Setting['vms-protected-items-per-page'].value_typed, 'page', %w(episodes.acts_as_ordered_order) ).add_join_accessor( 'episodes.acts_as_ordered_order', Proc.new{|o| o.acts_as_ordered_order } )
	end
	def show
		if params[:id]
			@show = Show.find( params[:id] )
		else
			@show = Show.first
		end
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'add', { :action => 'new', :show_id => @show.id }, {:title => 'Add a new episode to this show'} unless @show.is_a?(ShowOfTag)
		}.section('View') {|s|
			s.link 'jump to episode', { :action => 'jump' }, {:title => 'Jump to an episode based on its numerical ID'}
		}
	end

	def info
		if !params[:id].to_i.eql?0
			@episode = Episode.find( params[:id], :readonly => true )
		else
			@episode = Episode.find_by_name( params[:id], :readonly => true )
		end
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		respond_to do |format|
			format.html {
				@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
					s.link 'title, description, image', { :action => 'version_dashboard', :id => @episode.id }, { :title => 'Change the title, description, or image for this episode' }
					s.link 'settings', { :action => 'edit', :id => @episode.id }, { :title => 'Change the publication date and comments' }
          s.link 'tags', { :controller => '/cms/episode_tags', :action => 'list', :id => @episode.id }, { :title => 'Add/remove tags for this episode' }
					s.link 'episode parts', { :controller => '/cms/episode_parts', :action => 'episode', :id => @episode.id }, { :title => 'Link up content to this episode' }
					s.link 'availability', { :action => 'master_availability', :id => @episode.id }, { :title => 'Speicify the times during which this episode will be visible to all visitors' }
					s.link 'membership required', { :action => 'free_availability', :id => @episode.id }, { :title => 'Specify the times during which this episode will be available to non-members (free to the public)' }
          s.link 'add to show dynamic lead', { :controller => '/cms/show_dl_episodes', :action => 'new', :id => @show.id, :episode_id => @episode.id }, { :title => 'Quick add to this show\'s dynamic lead' }
          s.link 'add to home page dynamic lead', { :controller => '/cms/show_dl_episodes', :action => 'new', :id => 0, :episode_id => @episode.id }, { :title => 'Quick add to the home page dynamic lead' }
					s.link 'destroy', { :action => 'destroy_confirm', :id => @episode.id }, {:title => 'Destroy this episode'}
				}.section('View'){|s|
          s.link 'dynamic lead order', { :controller => '/cms/show_dl_episodes', :action => 'index', :id => @show.id }, { :title => 'Change the order episodes appear in the show\'s home page Dynamic Lead' }
					s.link 'preview', { :action => 'preview', :id => @episode.id }, {:title => 'See how this episode will be displayed at any time you choose'}
					s.link 'comments', { :controller => '/cms/episode_comments', :action => 'episode', :id => @episode.id }, {:title => 'Review all of the user comments about this episode'}
				}
			}
			format.json {
				render :json => @episode.to_json( :methods => [:total_length_in_seconds,:full_urlized_title] ), :layout => false
			}
			format.xml {
				render :xml => @episode.to_xml( :methods => [:full_urlized_title] ), :layout => false
			}
		end
	end

	def version_dashboard
		@episode = Episode.find( params[:id], :readonly => true )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'edit this version', { :action => 'edit_version', :id => @episode.id, :version => @episode.current_version_or_latest.version_number_cache }, {  }
		}.section('View') {|s|
			s.link 'history', { :action => 'versions', :id => @episode.id }, { :title => 'See all changes made to this episode' }
		}
	end

	def version
		@episode_version = EpisodeVersion.find( params[:id], :readonly => true )
		@episode = @episode_version.episode
		respond_to do |format|
			format.json {
				render :json => @episode_version.to_json( :methods => [:version_number] )
			}
			format.xml {
				render :xml => @episode_version.to_xml( :methods => [:version_number] )
			}
		end
	end

	def version_for_episode
		@episode = Episode.find( params[:id], :readonly => true )
		@episode_version = @episode.version( params[:version].to_i )
		raise ActiveRecord::RecordNotFound.new( "Unable to find version ##{params[:version]}" ) if @episode_version.nil?
		respond_to do |format|
			format.json {
				render :json => @episode_version.to_json( :methods => [:version_number] )
			}
			format.xml {
				render :xml => @episode_version.to_xml( :methods => [:version_number] )
			}
		end
	end

	def current_version_or_latest
		@episode = Episode.find( params[:id], :readonly => true )
		@episode_version = @episode.current_version_or_latest
		respond_to do |format|
			format.json {
				render :json => @episode_version.to_json( :methods => [:version_number] )
			}
			format.xml {
				render :xml => @episode_version.to_xml( :methods => [:version_number] )
			}
		end
	end

	def new
		@show = Show.find( params[:show_id], :readonly => true )
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode = Episode.new
		@episode_version = EpisodeVersion.new
		@episode_version.version_comment = 'Initial version'
	end

	def create
		@show = Show.find( params[:show_id], :readonly => true )
		@episode = Episode.new( params[:episode] )
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode.show_id = @show.id
		@episode_version = EpisodeVersion.new( params[:episode_version] )
		@episode_version.editor_id = session[:user_id]
		@episode.comment_count = 0

		begin
			Episode.transaction do
				if @episode.save
					@episode_version.version_stub_id = @episode.id
					if @episode_version.save!
            # set the new version to be the current version
            @episode.current_version_id = @episode_version.id
            @episode.save
						flash[:msg] = 'New episode created'
						redirect_to :action => 'info', :id => @episode.id and return 
					end
				end
			end
		rescue
		end
		render :action => 'new' and return
	end

	def edit
		@episode = Episode.find( params[:id] )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
	end

	def update
		@episode = Episode.find( params[:id] )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		if @episode.update_attributes( params[:episode] )
			flash[:msg] = 'Episode udpated'
			redirect_to :action => 'info', :id => @episode.id
		else
			render :action => 'edit'
		end
	end

	def edit_version
		@episode = Episode.find( params[:id], :readonly => true )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@episode_old_version = @episode.version( params[:version].to_i )
		raise ActiveRecord::RecordNotFound.new if @episode_old_version.nil?
		@episode_version = @episode_old_version.new_from
	end

	def update_version
		@episode = Episode.find( params[:id] )
		@episode_old_version = @episode.version( params[:version].to_i )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		raise ActiveRecord::RecordNotFound.new if @episode_old_version.nil?
		@episode_version = @episode_old_version.new_from

		@episode_version.attributes=( params[:episode_version] )
		@episode_version.editor_id = session[:user_id]
		if @episode_version.save
			if params[:save_and_publish]   # only publish if they clicked save and publish
				@episode.current_version_id = @episode_version.id
				@episode.save
			end
			flash[:msg] = "New episode version #{@episode_version.version_number_cache}"
			redirect_to :action => 'info', :id => @episode.id and return 
		end
		render :action => 'edit_version'
	end

  def mark_version_as_current
    @episode_version = EpisodeVersion.find(params[:id])
    @episode = @episode_version.episode
    @episode.current_version_id = @episode_version.id
    if @episode.save
      redirect_to :action => 'version_dashboard', :id => @episode.id
    end
  end

	def destroy_confirm
		@episode = Episode.find params[:id]
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
	end

	def destroy
		@episode = Episode.find( params[:id] )
		@show = @episode.show
		@episode_pag = episode_show_pagination
		pn = @episode_pag.page_number_of_item( @episode ) # get Page number before we destroy this item
		show_id = @show.id
		if @episode.destroy
			flash[:msg] = "Episode destroyed"
			redirect_to :controller => '/cms/episodes', :action => 'show', :id => @show.id, :page => pn
		else
			# FIXME: What if episode is not deleted?
		end
	end

	def versions
		@episode = Episode.find( params[:id] )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'EpisodeVersion', CW::SortOrder.desc('id'), {:conditions => ['version_stub_id = ?',@episode.id]}, Setting['vms-protected-items-per-page'].value_typed )
	end

	def master_availability
		@episode = Episode.find( params[:id] )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@availabilities = @episode.episode_publish_schedule_dates
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'add', { :action => 'new_master_availability', :id => @episode.id }, { :title => 'Add a range of time between which this episode will be visible' }
		}
	end

	def free_availability
		@episode = Episode.find( params[:id] )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@availabilities = @episode.episode_free_schedule_dates
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'add', { :action => 'new_free_availability', :id => @episode.id }, { :title => 'Add a range of time between which this episode will be free and not require a user account' }
		}
	end

	def new_master_availability
		@episode = Episode.find( params[:id] )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@availability = EpisodePublishScheduleDate.new
		@availability.start_at = Time.now
		@availability.end_at = @availability.start_at + 3.month
	end

	def create_master_availability
		@episode = Episode.find( params[:id] )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@availability = EpisodePublishScheduleDate.new( params[:availability] )
		@availability.exclusivity_id = @episode.id
		if @availability.save
			flash[:msg] = "Master Availability created"
			redirect_to :action => 'master_availability', :id => @episode.id
		else
			render :action => 'new_master_availability'
		end
	end

	def edit_master_availability
		@availability = EpisodePublishScheduleDate.find( params[:id] )
		@episode = @availability.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
	end

	def update_master_availability
		@availability = EpisodePublishScheduleDate.find( params[:id] )
		@episode = @availability.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		if @availability.update_attributes( params[:availability] )
			flash[:msg] = "Master Availability updated"
			redirect_to :action => 'master_availability', :id => @availability.episode.id
		else
			render :action => 'edit_master_availability'
		end
	end

	def destroy_master_availability_confirm
		@availability = EpisodePublishScheduleDate.find( params[:id] )
		@episode = @availability.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
	end

	def destroy_master_availability
		@availability = EpisodePublishScheduleDate.find( params[:id] )
		@episode = @availability.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@availability.destroy
		redirect_to :action => 'master_availability', :id => @availability.episode.id
	end



	def new_free_availability
		@episode = Episode.find( params[:id] )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@availability = EpisodeFreeScheduleDate.new
		@availability.start_at = Time.now
		@availability.end_at = @availability.start_at + 3.month
	end

	def create_free_availability
		@episode = Episode.find( params[:id] )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@availability = EpisodeFreeScheduleDate.new( params[:availability] )
		@availability.exclusivity_id = @episode.id
		if @availability.save
			flash[:msg] = "Free Availability created"
			redirect_to :action => 'free_availability', :id => @episode.id
		else
			render :action => 'new_free_availability'
		end
	end

	def edit_free_availability
		@availability = EpisodeFreeScheduleDate.find( params[:id] )
		@episode = @availability.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
	end

	def update_free_availability
		@availability = EpisodeFreeScheduleDate.find( params[:id] )
		@episode = @availability.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		if @availability.update_attributes( params[:availability] )
			flash[:msg] = "Free Availability updated"
			redirect_to :action => 'free_availability', :id => @availability.episode.id
		else
			render :action => 'edit_free_availability'
		end
	end

	def destroy_free_availability_confirm
		@availability = EpisodeFreeScheduleDate.find( params[:id] )
		@episode = @availability.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
	end

	def destroy_free_availability
		@availability = EpisodeFreeScheduleDate.find( params[:id] )
		@episode = @availability.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@availability.destroy
		redirect_to :action => 'free_availability', :id => @availability.episode.id
	end

	def move_episode_order_down
		@episode = Episode.find params[:id]
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@episode.move_order_up
		flash[:msg] = 'Episode moved down'
		
		redirect_to :action => 'show', :id => @episode.show.id, :page => episode_show_pagination.page_number_of_item(@episode)
	end

	def move_episode_order_up
		@episode = Episode.find params[:id]
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@episode.move_order_down
		flash[:msg] = 'Episode moved up'
		redirect_to :action => 'show', :id => @episode.show.id, :page => episode_show_pagination.page_number_of_item(@episode)
	end

	def move_episode_to_top
		@episode = Episode.find params[:id]
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@episode.move_order_to( :last )
		flash[:msg] = 'Episode moved to the top'
		redirect_to :action => 'show', :id => @episode.show.id, :page => episode_show_pagination.page_number_of_item(@episode)
	end

	def move_episode_to_bottom
		@episode = Episode.find params[:id]
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@episode.move_order_to( :first )
		flash[:msg] = 'Episode moved to the top'
		redirect_to :action => 'show', :id => @episode.show.id, :page => episode_show_pagination.page_number_of_item(@episode)
	end

	def move_episode_to_location
		@episode = Episode.find params[:id]
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@episode.move_order_to( @episode.acts_as_ordered_count_in_my_exclusivity - params[:location].to_i )
		flash[:msg] = 'Episode moved to the top'
		redirect_to :action => 'show', :id => @episode.show.id, :page => episode_show_pagination.page_number_of_item(@episode)
	end

	def preview
		@episode = Episode.find( params[:id] )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
	end

	def perform_preview
		@episode = Episode.find( params[:id] )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = episode_show_pagination
		@preview_time = CW::StandAloneTimeHelper.new( params[:preview_time].merge( :z => 'local' ) )
		pt = @preview_time.t.utc
		if @episode.current_version.nil?
			# Ensure that the version exists, otherwise will 500-level errors. This helps the user fix the problem
			flash[:msg] = "That episode has no current version, please schedule one during your desired preview time"
			redirect_to( :action => 'versions', :id => @episode.id ) and return
		else
			redirect_to( url_to_episode( @show.scheduled_version_current_or_last_version, @episode.current_version_or_latest ).merge( :admin_preview_at_time => pt.to_i ) )
		end
	end


	def jump
		@show_pag = Cms::ShowsController.list_pagination( self )
	end


end
