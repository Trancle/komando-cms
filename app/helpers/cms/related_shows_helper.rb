module Cms::RelatedShowsHelper

	def show_link_name( s )
		link_to( h( s.scheduled_version_current_or_last_version_cache.title ), :controller => '/cms/shows', :action => 'info', :id => s.id )
	end

end
