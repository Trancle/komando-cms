class Cms::EpisodePartsController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :create, :update, :destroy

	def episode_part_episode_show_pagination
		self.class.episode_part_episode_show_pagination( self, @episode )
	end; protected :episode_part_episode_show_pagination
	def self.episode_part_episode_show_pagination( controller, episode ); CW::Pagination::Model::ActiveRecord.new( controller, 'EpisodePart', CW::SortOrder.asc('name'), { :conditions => ['episode_id = ?', episode.id] }, Setting['vms-protected-items-per-page'].value_typed ); end; protected :episode_part_episode_show_pagination
	def episode
		@episode = Episode.find( params[:id], :readonly => true )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = Cms::EpisodesController.episode_show_pagination( self, @show )
		@ep_part_pag = episode_part_episode_show_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'add', { :action => 'new', :episode_id => @episode.id }, { :title => 'Link this episode to video content' }
		}
	end

	def show
		@episode_part = EpisodePart.find( params[:id] )
		@episode = @episode_part.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = Cms::EpisodesController.episode_show_pagination( self, @show )
		@ep_part_pag = episode_part_episode_show_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'edit', {:action => 'edit', :id => @episode_part.id }, {:title => 'Change this episode part information'}
			s.link 'destroy', {:action => 'destroy_confirm', :id => @episode_part.id }, {:title => 'Remove this episode part'}
		}
	end

	def new
		@episode = Episode.find( params[:episode_id], :readonly => true )
		@episode_part = EpisodePart.new
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = Cms::EpisodesController.episode_show_pagination( self, @show )
	end

	def create
		@episode = Episode.find( params[:episode_id], :readonly => true )
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = Cms::EpisodesController.episode_show_pagination( self, @show )
		@ep_part_pag = episode_part_episode_show_pagination
		@episode_part = EpisodePart.new( params[:episode_part] )
		@episode_part.episode_id = @episode.id

		if @episode_part.save
			redirect_to :action => 'episode', :id => @episode.id and return
		else
			render :action => 'new' and return
		end
	end

	def edit
		@episode_part = EpisodePart.find( params[:id] )
		@episode = @episode_part.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = Cms::EpisodesController.episode_show_pagination( self, @show )
		@ep_part_pag = episode_part_episode_show_pagination
	end

	def update
		@episode_part = EpisodePart.find( params[:id] )
    @episode = @episode_part.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = Cms::EpisodesController.episode_show_pagination( self, @show )
		@ep_part_pag = episode_part_episode_show_pagination
		if @episode_part.update_attributes( params[:episode_part] )
			redirect_to :action => 'episode', :id => @episode_part.episode_id
		else
			render :action => 'edit' and return
		end
	end

	def destroy_confirm
		@episode_part = EpisodePart.find params[:id]
		@episode = @episode_part.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = Cms::EpisodesController.episode_show_pagination( self, @show )
		@ep_part_pag = episode_part_episode_show_pagination
	end

	def destroy
		@episode_part = EpisodePart.find params[:id]
		@episode = @episode_part.episode
		@show = @episode.show
		@show_pag = Cms::ShowsController.list_pagination( self )
		@episode_pag = Cms::EpisodesController.episode_show_pagination( self, @show )
		@ep_part_pag = episode_part_episode_show_pagination
		pn = @ep_part_pag.page_number_of_item( @episode_part ) # Get the page number before delete
		@episode_part.destroy
		flash[:msg] = "Episode Part destroyed"
		redirect_to :action => 'episode', :id => @episode_part.episode.id, :page => pn
	end
end
