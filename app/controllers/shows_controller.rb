class ShowsController < ApplicationController
	include ShowsHelper
	layout 'show'

	hide_action :lookup_show_and_if_found

	skip_filter :require_login
	skip_filter :require_administrator_user


  # This is the listing of shows
  def index

    per_page = params[:per_page] || 20
    per_page = [per_page,100].min # limit show episodes per page to 100 maximum for speed reasons

    @pagination = CW::Pagination::Model::ActiveRecord.new( self, "Show", (CW::SortOrder.new - 'id'), Show.find_available_show_options, per_page, 'page' )


    @time = Time.now.utc
    @shows = @pagination.items_for_current_page
    respond_to do |format|
      format.html do
        @show_drops = @shows.map{|show| ShowDrop.new(show,show.scheduled_version_current_or_last_version,self,@time) }
        @layout = ( @layout_override || PageLayout.first( :conditions => "programmatic_name = 'shows-listing-page'" ).scheduled_version_current( @time ) ).layout
        render :action => 'index', :layout => 'shows', :type => 'text/html'
      end

      format.xml do
        render :action => 'index.xml', :layout => false, :type => 'text/xml'
      end

      format.json do
        response.headers['Access-Control-Allow-Origin'] = '*'
        render :action => 'index.json', :layout => false, :type => 'application/javascript'
      end
    end
  end


	def episodes
		return unless lookup_show_and_if_found do
			@show_version = @show.scheduled_version_current(@time)

      per_page = (params[:per_page] || @show.episodes_per_page).to_i
      skip_episode_ids = []
      if params[:skip_episode_ids]
        skip_episode_ids = params[:skip_episode_ids].split(',').map{|i| i.to_i}
      end
      per_page = [per_page,100].min # limit show episodes per page to 100 maximum for speed reasons



      # Look up episodes
      opts = Episode.find_available_episode_for_show_options( @show.id, {}, @time ) # Skip first 5, as they're in the DL

      if params[:format].nil? or params[:format].eql?('html')
        dl_opts = Episode.find_available_episode_for_show_options( @show.id, {:limit => 5} )
        dl_opts[:order] = Episode.order_options('DESC')[:order]
        @dl_episodes = Episode.all( dl_opts )
        # skip the episodes in the DL in the pagination
        skip_episode_ids = @dl_episodes.map{|e| e.id}
      end

      unless skip_episode_ids.empty?
        opts[:conditions][0] << ' AND ( episodes.id NOT IN (' + skip_episode_ids.map{|e| '?'}.join(',') + ') )'
        skip_episode_ids.each{|e| opts[:conditions] << e}
      end


      opts[:include] = [ {:current_version => :episode_still_image}, {:video_content_names => :video_contents}, :episode_free_schedule_dates ]
			@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'Episode', Episode.order_sort_order.invert, opts, per_page, 'page', %w(episodes.acts_as_ordered_order) )
      @episodes = @pagination.items_for_current_page

			respond_to do |format|
				format.html do

					logger.debug 'show_drop creating'
					@show_drop = ShowDrop.new(@show,@show_version,self,@time)
					@layout = ( @layout_override || PageLayout.first( :conditions => "programmatic_name = 'shows-episodes-page'" ).scheduled_version_current( @time ) ).layout
				end

				format.xml do
					render :action => 'info.xml', :layout => false, :type => 'text/xml'
				end

				format.json do
          response.headers['Access-Control-Allow-Origin'] = '*'
					render :action => 'info.json', :layout => false, :type => 'application/javascript'
				end
			end
		end
	end

	def latest
		lookup_show_and_if_found do
			ep = @show.latest_episode( {}, @time )
			if ep
				redirect_to( url_to_episode( @show.scheduled_version_current_or_last_version, ep.current_version ) )
			else
				redirect_to( url_to_show( @show.scheduled_version_current_or_last_version ) )
			end
		end and return
	end

	def lookup_show_and_if_found( &block )
		@show = nil
		if params[:title] and !params[:title].empty?
			@show = Show.first( Show.find_available_show_by_url_title_options( params[:title], {}, @time ) )
		end

		if @show.nil?
			# nothing found, do a search
			redirect_to :controller => '/search', :action => 'find', :q => (Show.urlize(params[:title])) and return false
		else
			yield( @show )
		end

		return true
  end

end
