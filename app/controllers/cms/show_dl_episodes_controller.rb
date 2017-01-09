class Cms::ShowDlEpisodesController < ApplicationController
  include ShowsHelper
  layout 'admin'
  attr_reader :action_nav
  helper CW::ActionNav::View

  skip_filter :enable_admin_layout_preview
  skip_filter :enable_admin_preview_at_time


  require_post_method_for :create, :destroy, :move_episode_order_down, :move_episode_order_up, :move_episode_order_top, :move_episode_order_bottom, :move_episode_to_location
  hide_action :load_show, :ep_pagination

  def ep_pagination
    @pagination = CW::Pagination::Model::ActiveRecord.new( self, 'ShowDlEpisode', CW::SortOrder.desc('acts_as_ordered_order'), {:conditions => ['show_id = ?',@show_id]}, Setting['vms-protected-items-per-page'].value_typed )
  end

  # List the order of the episodes for the show ID. If the ID is zero, it's for the home page.
  def index
    load_show
    ep_pagination
    respond_to do |format|
      format.html {
        @action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
          s.link 'add', { :action => 'new', :id => @show_id }, { :title => 'Add an episode to the front of the list' }
        }
        render :action => 'index'
      }
    end
  end

  def list
    index
  end

  def new
    load_show
    @dl = ShowDlEpisode.new
    @dl.episode_id = params[:episode_id]
  end

  def create
    load_show
    @dl = ShowDlEpisode.new
    @episode = Episode.find( params[:dl][:episode_id] )
    if !@episode.show_id.eql?(@show_id) and !@show_id.eql?(0)
      # show id's don't match. Tried to add an episode from another show
      @dl.errors.add_to_base "Tried to add an episode from show #{@episode.show.scheduled_version_current_or_last_version.title} (#{@episode.show_id}), but you're currently in show #{@show.scheduled_version_current_or_last_version.title} (#{@show_id})"
      render :action => 'new'
    else
      begin
        @dl.show_id = @show_id || 0
        @dl.episode_id = @episode.id
        @dl.save
        redirect_to( :action => 'index', :id => @show_id || 0 )
      rescue ActiveRecord::RecordNotFound => e
        @dl.errors.add_to_base 'Episode not found'
        render :action => 'new'
      end
    end
  end




  def move_episode_order_down
    @dl = ShowDlEpisode.find params[:id]
    @show = nil
    @show_id = 0
    unless @dl.show_id.eql?(0)
      @show = Show.find(@dl.show_id)
      @show_id = @show.id
    end
    ep_pagination
    @dl.move_order_up
    flash[:msg] = 'Episode moved down'
    redirect_to :action => 'index', :id => @show_id, :page => @pagination.page_number_of_item(@dl)
  end

  def move_episode_order_up
    @dl = ShowDlEpisode.find params[:id]
    @show = nil
    @show_id = 0
    unless @dl.show_id.eql?(0)
      @show = Show.find(@dl.show_id)
      @show_id = @show.id
    end
    ep_pagination
    @dl.move_order_down
    flash[:msg] = 'Episode moved up'
    redirect_to :action => 'index', :id => @show_id, :page => @pagination.page_number_of_item(@dl)
  end

  def move_episode_to_top
    @dl = ShowDlEpisode.find params[:id]
    @show = nil
    @show_id = 0
    unless @dl.show_id.eql?(0)
      @show = Show.find(@dl.show_id)
      @show_id = @show.id
    end
    ep_pagination
    @dl.move_order_to( :last )
    flash[:msg] = 'Episode moved to the top'
    redirect_to :action => 'index', :id => @show_id, :page => @pagination.page_number_of_item(@dl)
  end

  def move_episode_to_bottom
    @dl = ShowDlEpisode.find params[:id]
    @show = nil
    @show_id = 0
    unless @dl.show_id.eql?(0)
      @show = Show.find(@dl.show_id)
      @show_id = @show.id
    end
    ep_pagination
    @dl.move_order_to( :first )
    flash[:msg] = 'Episode moved to the top'
    redirect_to :action => 'index', :id => @show_id, :page => @pagination.page_number_of_item(@dl)
  end

  def move_episode_to_location
    @dl = ShowDlEpisode.find params[:id]
    @show = nil
    @show_id = 0
    unless @dl.show_id.eql?(0)
      @show = Show.find(@dl.show_id)
      @show_id = @show.id
    end
    ep_pagination
    @dl.move_order_to( @dl.acts_as_ordered_count_in_my_exclusivity - params[:location].to_i )
    flash[:msg] = 'Episode moved to the top'
    redirect_to :action => 'index', :id => @show_id, :page => @pagination.page_number_of_item(@dl)
  end


  def destroy
    @dl = ShowDlEpisode.find(params[:id])
    @show = nil
    @show_id = 0
    unless @dl.show_id.eql?(0)
      @show = Show.find(@dl.show_id)
      @show_id = @show.id
    end
    ep_pagination
    pgnum = @pagination.page_number_of_item(@dl)
    @dl.destroy
    flash[:msg] = "Removed episode #{@dl.episode_id} from the list"
    redirect_to :action => 'index', :id => @show_id, :page => pgnum
  end



  def load_show
    @show = nil
    @show_id = 0 # also the exclusivity id
    if params.has_key?(:id) and !params[:id].to_i.eql?(0)
      @show = Show.find(params[:id])
      @show_id = @show.id
    end
  end

end
