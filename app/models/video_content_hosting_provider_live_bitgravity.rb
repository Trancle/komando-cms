class VideoContentHostingProviderLiveBitgravity < VideoContentHostingProviderLive
	ffma_create_attribute 'configuration', 'hls_url', :string
  ffma_create_attribute 'configuration', 'http_url', :string
  ffma_create_attribute 'configuration', 'universal_url', :string
	ffma_create_attribute 'configuration', 'secure_secret', :string
  ffma_create_attribute 'configuration', 'time_interval_in_seconds', :integer, 3600*3 + 600 # 3 hours, 10 minutes

  ffma_create_attribute 'configuration', 'allowed_countries', :string
  ffma_create_attribute 'configuration', 'disallowed_countries', :string
  ffma_create_attribute 'configuration', 'allowed_metros', :string
  ffma_create_attribute 'configuration', 'disallowed_metros', :string

  ffma_create_attribute 'configuration', 'enforce_ip', :bool, true
  ffma_create_attribute 'configuration', 'enforce_user_agent', :bool, true




  validates_presence_of 'hls_url'
  validates_length_of 'hls_url', :in => 3..2048
  validates_presence_of 'http_url'
  validates_length_of 'http_url', :in => 3..2048

	validates_presence_of 'secure_secret'
	validates_length_of 'secure_secret', :in => 10..64

	validates_presence_of 'time_interval_in_seconds'
	validates_numericality_of 'time_interval_in_seconds', :only_integer => true, :greater_than => 0


  validates_length_of 'allowed_countries', :in => 0..2048
  validates_length_of 'disallowed_countries', :in => 0..2048
  validates_length_of 'allowed_metros', :in => 0..2048
  validates_length_of 'disallowed_metros', :in => 0..2048



	def content_model_name
		'VideoContentHostedLiveBitgravity'
	end


  def sign_uri( uri, client_ip_address, client_user_agent, opts = {} )
    path = URI.parse(uri).path
    append = query_builder( client_ip_address, client_user_agent, opts )
    append << 'h=' + uri_signature( path, client_ip_address, client_user_agent, opts )

    # return the URL with params, signed
    uri + '?' + append.join('&')
  end

  def query_builder( client_ip_address, client_user_agent, opts = {} )
    opts['e'] = (Time.now.utc + self.time_interval_in_seconds).to_i unless opts.has_key?('e')
    opts['a'] = self.allowed_countries if !opts.has_key?('a') and !self.allowed_countries.empty?
    opts['d'] = self.disallowed_countries if !opts.has_key?('d') and !self.disallowed_countries.empty?
    opts['am'] = self.allowed_metros if !opts.has_key?('am') and !self.allowed_metros.empty?
    opts['dm'] = self.disallowed_metros if !opts.has_key?('dm') and !self.disallowed_metros.empty?
    opts['i'] = client_ip_address if !opts.has_key?('i') and self.enforce_ip
    opts['u'] = client_user_agent if !opts.has_key?('u') and self.enforce_user_agent

    append = []
    %w(e a d am dm i u).each do |field|
      append << "#{field}=#{CGI.escape(opts[field].to_s)}" if opts.has_key?(field)
    end
    append
  end


  def uri_signature( path, client_ip_address, client_user_agent, opts = {} )
    plain = self.secure_secret + path
    plain << '?' unless opts.empty?
    plain << query_builder( client_ip_address, client_user_agent, opts ).join('&')
    OpenSSL::Digest::MD5.hexdigest( plain )
  end

end
