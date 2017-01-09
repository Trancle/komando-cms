class Cms::EpisodeTagsController < ApplicationController
	layout 'admin'
  attr_reader :action_nav
  helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

  require_post_method_for :replace, :add, :destroy, :create




  # List the tags as a comma-separated string for an episode
  def list
    @episode = Episode.find(params[:id])
    @show = @episode.show
    respond_to do |format|
      format.html {
        @action_nav = CW::ActionNav::Controller::Base.new.section( 'Change' ) do |change|
          change.link('new',{:action => 'new',:id => @episode.id})
          change.link('replace',{:action => 'edit',:id => @episode.id})
        end
        @taggings = @episode.taggings
        render :list
      }
      format.json { render :json => @episode.tags_as_string }
    end
  end

  def edit
    @episode = Episode.find(params[:id])
    @show = @episode.show
    @tag = EpisodeTag.new( :tag => @episode.tags_as_string )
    respond_to do |format|
      format.html {
        render 'edit'
      }
      format.json { render :json => @episode.tags_as_string }
    end
  end

  def replace
    @episode = Episode.find(params[:id])
    @episode.assign_tags(params[:tags] || '')
    respond_to do |format|
      format.html {
        redirect_to :action => 'list', :id => @episode.id
      }
      format.json { render :json => @episode.tags_as_string }
    end
  end

  def suggest
    respond_to do |format|
      format.json do
        if params[:tags].nil? or params[:tags].empty?
          render :json => ''
        else
          render :json => Episode.suggest_tags(params[:tags], 10) # limit to 10 suggestions
        end
      end
    end
  end

  def destroy
    @episode_tagging = EpisodeTagging.find(params[:id])
    @episode = @episode_tagging.episode
    if @episode.remove_tags( [@episode_tagging] )
      flash[:msg] = 'Tag removed'
    end
    redirect_to :action => :list, :id => @episode.id
  end

  def new
    @episode = Episode.find(params[:id])
    @show = @episode.show
    @tag = EpisodeTag.new
  end

  def create
    @episode = Episode.find(params[:id])
    @episode.add_tags( Episode.tag_string_to_array(params[:tag]['tag']) )
    redirect_to :action => 'list', :id => @episode.id
  end
end
