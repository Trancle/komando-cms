class VideoContentEmbeddedOnDemandYouTube < VideoContentEmbeddedOnDemand
	
	ffma_create_attribute 'embed_attrs', 'video_id', :string
	ffma_create_attribute 'embed_attrs', 'auto_play', :bool, false
	ffma_create_attribute 'embed_attrs', 'show_related_videos', :bool, false
	ffma_create_attribute 'embed_attrs', 'show_video_information', :bool, false
	ffma_create_attribute 'embed_attrs', 'start_offset_in_seconds', :integer, 0
	ffma_create_attribute 'embed_attrs', 'auto_hide_controls', :integer, 1
	ffma_create_attribute 'embed_attrs', 'display_controls', :bool, true
	ffma_create_attribute 'embed_attrs', 'cc_load_policy', :bool, false
	ffma_create_attribute 'embed_attrs', 'loop_video', :bool, false
	ffma_create_attribute 'embed_attrs', 'allow_full_screen', :bool, true
	ffma_create_attribute 'embed_attrs', 'show_video_annotations', :bool, false
	ffma_create_attribute 'embed_attrs', 'modest_branding', :bool, true

	def embed_type
		'YouTube'
	end
	def short_name
		'YouTube embedded on demand ' + video_id
  end

  def video_id=( v )
    if !v.nil? and !v.empty?
      v.strip!
    end
    embed_attrs['video_id'] = v
  end

	validates_presence_of :video_id
	validates_length_of :video_id, :in => 4..32
	validates_format_of :video_id, :with => /[a-z0-9\-_]+/i
	validates_numericality_of :start_offset_in_seconds, :allow_nil => true, :greater_than_or_equal_to => 0, :only_integer => true, :message => "value '{{value}}' is not a number"
	validates_presence_of :auto_hide_controls
	validates_inclusion_of :auto_hide_controls, :in => 0..2


	def url_options( opts = {} )
		opts['start'] = self.start_offset_in_seconds.to_s if !self.start_offset_in_seconds.nil? and self.start_offset_in_seconds > 0
		opts['autohide'] = self.auto_hide_controls
		opts['autoplay'] = ( self.auto_play ? '1' : '0' )
		opts['rel'] = ( self.show_related_videos ? '1' : '0' )
		opts['showinfo'] = ( self.show_video_information ? '1' : '0' )
		opts['controls'] = ( self.display_controls ? '1' : '0' )
		opts['cc_load_policy'] = '1' if self.cc_load_policy
		opts['loop'] =  ( self.loop_video ? '1' : '0' )
		opts['fs'] = ( self.allow_full_screen ? '1' : '0' )
		opts['iv_load_policy'] = ( self.show_video_annotations ? '1' : '3' )
		opts['modestbranding'] = ( self.modest_branding ? '1' : '0' )
    opts['enablejsapi'] = '1' # always enable the javascript API
    opts['allowfullscreen'] = '1' # always allow full screen
		opts
	end

	def data_url( other_options = {} )
#fs=1&amp;showinfo=#{options[:show_video_information] ? '1' : '0'}&amp;autoplay=#{options[:auto_play] ? '1' : '0'}&amp;rel=#{options[:show_related_videos] ? '1' : '0'}&amp;start=#{options[:start_offset]}&amp;iv_load_policy=3"
		"https://www.youtube.com/embed/#{video_id}?" + url_options( other_options ).collect{|k,v| k.to_s + '=' + v.to_s}.join('&')
	end

	def watch_url
		"http://www.youtube.com/watch?v=#{video_id}"
	end

	def poster_image_url
		"http://img.youtube.com/vi/#{video_id}/0.jpg"
	end


end
