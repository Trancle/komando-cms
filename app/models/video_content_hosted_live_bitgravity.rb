class VideoContentHostedLiveBitgravity < VideoContentHostedLive
	ffma_create_attribute 'hosting_attrs', 'stream_name', :string

	validates_presence_of 'stream_name'
	validates_format_of 'stream_name', :with => /[a-z0-9_\-]/i

	def short_name
		self.stream_name
	end

	def hls_uri( client_ip, client_ua, opts = {} )
    q = video_content_hosting_provider.query_builder(
        client_ip,
        client_ua,
        opts)
    # can't sign using the HLS URL, only the HTTP url... odd...
    q << 'h=' + uri_signature( client_ip, client_ua, opts )

    video_content_hosting_provider.hls_url + '/' + self.stream_name + '/playlist.m3u8?' + q.join('&')
  end
  def universal_uri( client_ip, client_ua, opts = {} )
    q = video_content_hosting_provider.query_builder(
        client_ip,
        client_ua,
        opts)
    # can't sign using the HLS URL, only the HTTP url... odd...
    q << 'h=' + uri_signature( client_ip, client_ua, opts )

    video_content_hosting_provider.universal_url + '/' + self.stream_name + '?' + q.join('&')
  end

  # Computes the multi-variable bit rate URL
  def universal_mvbr_uri( client_ip, client_ua, opts = {} )
    q = video_content_hosting_provider.query_builder(
        client_ip,
        client_ua,
        opts)
    # can't sign using the HLS URL, only the HTTP url... odd...
    q << 'h=' + uri_mvbr_signature( client_ip, client_ua, opts )
    q << 'bgsecuredir=1'

    video_content_hosting_provider.universal_url + '/' + self.stream_name + '?' + q.join('&')
  end
  def http_uri( client_ip, client_ua, opts = {} )
    q = video_content_hosting_provider.query_builder(
        client_ip,
        client_ua,
        opts)
    # can't sign using the HLS URL, only the HTTP url... odd...
    q << 'h=' + uri_signature( client_ip, client_ua, opts )

    video_content_hosting_provider.http_url + '/' + self.stream_name + '?' + q.join('&')
  end

  def uri_signature( client_ip, client_ua, opts = {} )
    self.video_content_hosting_provider.uri_signature( URI.parse(video_content_hosting_provider.http_url).path + '/' + self.stream_name,
                                                       client_ip,
                                                       client_ua,
                                                       opts )
  end

  def uri_mvbr_signature( client_ip, client_ua, opts = {} )
    path = URI.parse(video_content_hosting_provider.universal_url).path.gsub('/content:cdn-live','')
    path = path[/\A.*\/secure/] unless path[/\A.*\/secure/].nil?
    self.video_content_hosting_provider.uri_signature( path + '/',
                                                       client_ip,
                                                       client_ua,
                                                       opts )
  end

  # manual override for live streams
  def mime_type
    'application/x-mpegURL'
  end

end
