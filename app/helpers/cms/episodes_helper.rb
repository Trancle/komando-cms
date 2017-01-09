module Cms::EpisodesHelper

	def full_episode_name( ep )
		link_to( ep.show.scheduled_version_current_or_last_version_cache.title, :controller => '/cms/episodes', :action => 'show', :id => ep.show.id ) + ": " + ep.current_version_or_latest.title
	end

	def episode_title( episode )
		h( episode.current_version_or_latest.title )
	end
end
