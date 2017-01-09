class Cms::ShowTagsController < ApplicationController
	layout 'admin'
  attr_reader :action_nav
  helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

  require_post_method_for :replace, :add, :destroy, :create




  # List the tags as a comma-separated string for an episode
  def list
    @show = Show.find(params[:id])
    respond_to do |format|
      format.html {
        @action_nav = CW::ActionNav::Controller::Base.new.section( 'Change' ) do |change|
          change.link('new',{:action => 'new',:id => @show.id})
          change.link('replace',{:action => 'edit',:id => @show.id})
        end
        @taggings = @show.taggings
        render :list
      }
      format.json { render :json => @show.tags_as_string }
    end
  end

  def edit
    @show = Show.find(params[:id])
    @tag = ShowTag.new( :tag => @show.tags_as_string )
    respond_to do |format|
      format.html {
        render 'edit'
      }
      format.json { render :json => @show.tags_as_string }
    end
  end

  def replace
    @show = Show.find(params[:id])
    @show.assign_tags(params[:tags] || '')
    respond_to do |format|
      format.html {
        redirect_to :action => 'list', :id => @show.id
      }
      format.json { render :json => @show.tags_as_string }
    end
  end

  def suggest
    respond_to do |format|
      format.json do
        if params[:tags].nil? or params[:tags].empty?
          render :json => ''
        else
          render :json => Show.suggest_tags(params[:tags], 10) # limit to 10 suggestions
        end
      end
    end
  end

  def destroy
    @show_tagging = ShowTagging.find(params[:id])
    @show = @show_tagging.episode
    if @show.remove_tags( [@show_tagging] )
      flash[:msg] = 'Tag removed'
    end
    redirect_to :action => :list, :id => @show.id
  end

  def new
    @show = Show.find(params[:id])
    @tag = ShowTag.new
  end

  def create
    @show = Show.find(params[:id])
    @show.add_tags( Show.tag_string_to_array(params[:tag]['tag']) )
    redirect_to :action => 'list', :id => @show.id
  end
end
