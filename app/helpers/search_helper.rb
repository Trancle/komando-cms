module SearchHelper

	def result_link( r )
    case r.result.class.name
      when 'Episode'
        link_to( r.result.current_version.title, url_to_episode( r.result.show.r.scheduled_version_current_cache, result.current_version ) )
      when 'Show'
        link_to( r.result.scheduled_version_current_cache.title, url_to_show( r.result.scheduled_version_current_or_last_version ) )
      else
        ''
    end
	end

	def result_relevancy( r )
		(r.rank*100.0).to_i.to_s + '%'
	end

end
