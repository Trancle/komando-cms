class SearchController < ApplicationController
	helper ShowsHelper
	include ShowsHelper
	layout 'search'

	skip_filter :require_login
	skip_filter :require_administrator_user

	hide_action :create_liquid_layout

	def index
		# display the search box
		@terms = ''
	end

	def find
		# perform the search query on ID
# search over episodes and shows

		# search terms from a form
		@terms = params[:q] || ''

		# terms specified in a url after /search/STUFF
		if params[:term]
			@terms = params[:term]


# remove URL stuff
			@terms.gsub!('-', ' & ')
		end

		# 404 rescue
		if params[:path]

			# If terms contains a dot, this means it's not a search, but a request for a resource.
			# If now, because the search controller has been hired to do this request, this file wasn't found
			# Also, if the first path param is "managed_file_resource_images" or other folders in /public, then it is trying to look up a still image or file. That means the image isn't found and we should 404 as well:
			# To avoid unnecessary file lookups, we should return a 404.
			if should_skip_search?
				# this will stop needless search processing for real, bona-fide 404 errors
				render :file => RAILS_ROOT + '/public/404.html', :layout => false, :status => 404 and return
			end


			@terms = params[:path].collect{|t| t.gsub( /[^0-9a-zA-Z]/, '' ) }.reject{|t| t.strip.empty? }.uniq.collect{|t| "\"#{t}\""}.join(' or ')
# remove URL stuff
			@terms.gsub!('-', ' & ')
		end


		@results = []

		@pagination = CW::Pagination::Model::ActiveRecord.new( self, "SearchResult", nil, {:terms => @terms}, Setting['vms-protected-search-results-per-page'].value_typed )
		# Save the query between pages
		@pagination.preserve_parameter_named( 'q' )
		unless @terms.empty?
			begin
				@results = @pagination.items_for_current_page

				case @results.size
					when 1
						# 301 status: moved permanently: tell spiders to no cache search results
						rd = case @results.first.result.class.name
								when 'Episode'
									url_for( url_to_episode( @results.first.result.show.scheduled_version_current_or_last_version, @results.first.result.current_version_or_latest ) )
                   when 'Show'
                     url_for( url_to_show( @results.first.result.scheduled_version_current_or_last_version ) )
                   when 'ShowOfTag'
                     url_for( url_to_show( @results.first.result.scheduled_version_current_or_last_version ) )
								else
									'/'
							end
						redirect_to( rd, :status => 301 )
					when 0
						create_liquid_layout
						render :status => 404, :layout => true
					else
						# just render
						# need to generate the layout
						create_liquid_layout
				end
			rescue ActiveRecord::StatementInvalid => s
				@message = "Sorry, I didn't understand for what you want to search"
				raise s if ENV['RAILS_ENV'].eql?'development'
				render :action => 'index'
			end
		else
			@results = []
			create_liquid_layout
		end
	end

	def create_liquid_layout
		@layout = ( @layout_override || PageLayout.first( :conditions => "programmatic_name = 'search-find-page'" ).scheduled_version_current( @time ) ).layout
  end


  private
  def should_skip_search?
    (!params[:path].empty? and ( params[:path].last.index('.')) or params[:path].first.eql?'managed_file_resource_images' or params[:path].first.eql?'themes' or params[:path].first.eql?'javascripts' or params[:path].first.eql?'images' or params[:path].first.eql?'stylesheets' or params[:path].join('/').start_with?(ResizedImagesCachePathVirtual.pathname) ) or params[:path].first.eql?('Liquid error: Unable to read image: ')
  end

end
