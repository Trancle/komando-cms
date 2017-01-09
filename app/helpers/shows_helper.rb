module ShowsHelper
	include Cms::PublicImagesHelper

	def link_to_watch_episode( episode, text, opts = {} )
		link_to( text, "/watch/#{episode.id}/#{episode.full_urlized_title}", opts )
	end

	def episode_image_tag( episode, episode_version )
		imgtag = nil
		if episode_version.episode_still_image
			opts = {  }
			opts[:class] = 'episode_still_image'
			opts[:class] += ' premium' unless episode.free?
		else
			return ''
		end
		tag('div', opts, true ) + link_to_watch_episode( episode, image_tag( episode_version.episode_still_image.virtual_path, :alt => episode_version.episode_still_image.alt_text ) ) + '</div>'
	end

# URL to Episode
#
# Creates a hash capable of specifying the URL of this episode given the title in this version
#
# @returns a hash with all the URL components to navigate (relativistically) to this episode complete with a SEO-rich title
	def url_to_episode( show_version, episode_version )
		{ :controller => '/watch', :action => episode_version.version_stub_id, :id => "#{show_version.url_title}-#{episode_version.url_title}" }
	end


	def url_to_show( show_version )
		{ :controller => '/' + show_version.url_title }
	end

end
