module WatchHelper

	def path_to_player_partial( video_content )
		r = ''
		# all content names contain the same content type. So, we need only the first one to determine the player type to use
		if video_content.is_a?(VideoContentEmbeddedOnDemand)
			r = "watch/players/embedded_on_demand/"
		elsif video_content.is_a?(VideoContentHostedOnDemand)
			r = "watch/players/hosted_on_demand/"
		else
			r = "watch/players/hosted_live/"
		end
		r += VideoContent.sub_subclass_name( video_content ).underscore
		r
	end


	def render_player( mfrn, episode = nil )
		return render_player_for_video_content( mfrn, mfrn.video_contents, episode )
	end

# Render player for video content
#
# Produces a string of HTML to embed players. This one displays only the content given, automatically selected content from the managed file resource name.
#
# @param[in] video_contents Array of 1 or more VideoContent subclasses. Embedded on demand will accept ONLY 1 and will use ONLY the first element
# @param[in] episode Optional Episode instance record for use with fallback and ALT text
# @returns HTML embed code for the type of content used
	def render_player_for_video_content( mfrn, video_contents, episode = nil )
		return render( :partial => path_to_player_partial( video_contents.first ), :locals => { :managed_file_resource_name => mfrn, :video_contents => video_contents, :episode => episode } )
  end




  def hosted_on_demand_and_live_with_fallback_html( mfrn, sources, video_contents, fallback_html, episode = nil, video_options = {} )
    html5_tag_id = 'html5_player_mfrn_id_' + mfrn.id.to_s

    r = ''
    # x-webkit-airplay allows the video to be played using Airplay (Apple's video platform)
    video_options[:poster] = episode.current_version.still_image_virtual_path if episode
    r += tag( 'video', { :controls => 'controls', :preload => 'preload', :id => html5_tag_id, 'x-webkit-airplay' => 'allow', :class => 'kplayer' }.merge( video_options ), true )
    # how do we select ONLY the video_contents that will work with this tech?
    sources.each do |source|
      codecs = ''
      codecs << source['video_codec'] if source['video_codec']
      if source['audio_codec']
        codecs << ', ' unless codecs.empty?
        codecs << source['audio_codec']
      end
      mime_type = source['mime_type']
      mime_type << ';codecs=\"' + codecs + '\"' unless codecs.empty?
      r += tag( 'source', { :src => source['url'], :type => h(mime_type), 'data-bitrate' => "#{source['bitrate']}kbps", 'data-vertical-lines' => source['height'] } )
    end

    r += fallback_html
    r += '</video>'
    r
  end



  def hosted_on_demand_html5_with_fallback_limelight_flash_player( mfrn, video_contents, fallback_html, episode, video_options = {}, swf_options = {} )
    html5_tag_id = 'html5_player_mfrn_id_' + mfrn.id.to_s

    r = ''
    # x-webkit-airplay allows the video to be played using Airplay (Apple's video platform)
    video_options[:poster] = episode.current_version.still_image_virtual_path if episode
    r += tag( 'video', video_options.merge( { :controls => 'controls', :preload => 'preload', :id => html5_tag_id, 'x-webkit-airplay' => 'allow', :class => 'kplayer' } ), true )
    # how do we select ONLY the video_contents that will work with this tech?
    video_contents.each do |source|
      r += tag( 'source', { :src => source.http_llnw_url, :type => h(source.mime_type + ";codecs=\"#{source.video_codec}, #{source.audio_codec}\""), 'data-bitrate' => "#{source.bitrate}kbps", 'data-vertical-lines' => source.height } )
#r += tag( 'source', { :src => source.http_llnw_url, :type => h(source.mime_type) } )
    end

    # HTML5 FALLBACK
    # We're here, so their browser doesn't understand HTML5

    # We need to select a flash video... Select the MP4 with the lowest bitrate (most accessibility)
    flash_video = video_contents.to_a.select{|vc| vc.mime_type.eql?('video/mp4') }.min{|a,b| a.bitrate <=> b.bitrate }
    r += limelight_flash_player_on_demand_core_storage_insertion( flash_video.http_llnw_url, swf_options.merge( { :id => 'flash_player_mfrn_id_' + mfrn.id.to_s } ), fallback_html )
    r += '</video>'
    #r += javascript_tag("com_wojnosystems_html5_to_flash_fallback( \"##{html5_tag_id}\" );")
    r
  end

	def limelight_flash_player_on_demand_core_storage_insertion( media_url, swf_options, fallback_html )
		limelight_flash_player_generic_insertion( media_url, 'Streaming', swf_options, @controller.request.protocol + @controller.request.host_with_port + "/player.swf", fallback_html )
	end


# param_hash: param_hash['name'] = 'value' or value
	def limelight_flash_player_generic_insertion( media_url, stream_type, swf_options, swf_player_url, fallback_html = '<p>Flash not supported</p>', param_hash = {}, flash_vars = {} )
		r = ''

		default_params = {
			'movie' => swf_player_url,
			'allowScriptAccess' => 'always',
			'quality' => 'high',
			'allowFullScreen' => 'true',
			'bgcolor' => '#000'
		}

		param_hash = default_params.merge( param_hash )

		default_flash_vars = {
			'urls' => URI.escape('[{ "u": "' + media_url + '", "r": "0" }]').gsub('&','%26')
		}

		flash_vars = default_flash_vars.merge( flash_vars )

    #raise flash_vars['mediaURL'].gsub('&','&amp;').inspect

		r += tag( 'object', { :type => 'application/x-shockwave-flash', :data => swf_player_url }.merge( swf_options ), true )
		param_hash.each_pair do |k,v|
			r += tag( 'param', { :name => k, :value => v } )
    end
    r += "<param name=\"flashVars\" value=\"#{flash_vars.map{|k,v| "#{h(k.to_s)}=#{h(v.to_s)}" }.join('&amp;')}\"/>"
		r += fallback_html
		r += '</object>'
		r
	end

end
