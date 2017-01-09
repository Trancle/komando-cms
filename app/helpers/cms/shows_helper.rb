module Cms::ShowsHelper

	def show_title( show )
		h(show.scheduled_version_current_or_last_version_cache.title)
	end

end
