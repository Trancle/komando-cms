class VideoContentEmbeddedOnDemandVimeo < VideoContentEmbeddedOnDemand
	ffma_create_attribute 'embed_attrs', 'video_id', :string
	ffma_create_attribute 'embed_attrs', 'auto_play', :bool, false
	ffma_create_attribute 'embed_attrs', 'loop_video', :bool, false
	ffma_create_attribute 'embed_attrs', 'show_video_title', :bool, false
	ffma_create_attribute 'embed_attrs', 'show_video_byline', :bool, false
	ffma_create_attribute 'embed_attrs', 'show_user_portrait', :bool, false

	def embed_type
		'Vimeo'
	end

	def short_name
		'Vimeo embedded on demand ' + video_id
	end

	validates_presence_of :video_id
	validates_length_of :video_id, :in => 4..32
	validates_numericality_of :video_id, :greater_than => 0, :only_integer => true


	def url_options
		opts = {}
		opts['autoplay'] = ( self.auto_play ? '1' : '0' )
		opts['loop'] = ( self.loop_video ? '1' : '0' )
		opts['title'] = ( self.show_video_title ? '1' : '0' )
		opts['byline'] = ( self.show_video_byline ? '1' : '0' )
		opts['portrait'] = ( self.show_user_portrait ? '1' : '0' )
    opts['api'] = '1'
		opts
	end

	def src_url
#fs=1&amp;showinfo=#{options[:show_video_information] ? '1' : '0'}&amp;autoplay=#{options[:auto_play] ? '1' : '0'}&amp;rel=#{options[:show_related_videos] ? '1' : '0'}&amp;start=#{options[:start_offset]}&amp;iv_load_policy=3"
		"//player.vimeo.com/video/#{video_id}?" + url_options.collect{|k,v| k.to_s + '=' + v.to_s}.join('&')
	end
	def watch_url
		"http://vimeo.com/#{video_id}"
	end
end
