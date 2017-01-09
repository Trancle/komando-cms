module Cms::EpisodePartsHelper

	def episode_name_link( e )
		show = e.show
		show_title = show.scheduled_version_current_or_last_version_cache.title
		link_to( h( show_title ), :controller => '/cms/shows', :action => 'info', :id => show.id ) + ': ' + link_to( h( e.current_version_or_latest.title ), :controller => '/cms/episodes', :action => 'info', :id => e.id )
	end

end
