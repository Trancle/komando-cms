require "bitgravity/version"
require 'openssl'
require 'net/ftp'

=begin
BitGravity: API

Provides a set of classes to facilitate the interaction with BitGravity and it's features.

BitGravity operates by creating mirrors. You upload content to the bitgravity FTP server:
ftp.bitgravity.com (as of 2012-12-02)

When you log into the service with your username, the directory is automatically redirected to your company account root directory. You should see the directories: "secure" if you have secure streaming and "twistage-production" if you have BitGravity Video Director service. I also recommend creating a "free" directory to help with additional categorization, but you're free to place files in the root directory, if you wish, but I dont recommend it.

When files are to be downloaded, the same paths are used if you do not use CNAMEs to alias your progressive HTTP streaming service. If you do use a CNAME alias, you must include your company id as the first component of the URL path. This will be done for you (see SecureURL). Therefore, cannonical paths will be designated as those that do not assume you are using a CN for the hostname.  Use of a CNAME will be detected automatically based on the hostname used.

Quickstart Guide
Contact BitGravity and purchase their service. You need their CDN services known as, presently, Video Delivery. It will delivery other content as well (PDF, graphics, audio, etc). You will then need your FTP username, password and hostname and your company id, Shared secret (if you purchased the secure content delivery).

To upload a file to the CDN:
BitGravity.new( FTP_HOSTNAME, FTP_USERNAME, FTP_PASSWORD ).upload( PATH_TO_LOCAL_FILE, PATH_TO_REMOTE_DESTINATION )

And you're done.

To create a link to download that file, use the URL generator:
BitGravity::SecureUrl.new( SHARED_SECRET, HTTP_CDN_HOSTNAME, COMPANY_ID ).url( PATH_TO_REMOTE_DESTINATION )

That link will likely be a redirect, so you'll need to be sure your software is capable of following location headers if you intend to test it. Speaking of which, please see the test suites to get real examples of usage and to see how some of the guts come together to operate.
=end
module BitGravity

=begin
FTP

Facilitates the uploading and downloading of files to the BitGravity storage designated by BitGravity.
=end
  class Ftp
    attr_reader :host, :username
    def initialize( host, username, password )
      @host = host
      @username = username
      @password = password
    end


=begin
Upload

Upload a file to the server, create any folders in between
=end
    def upload( src, dst, &block )
      raise ArgumentError.new("src file does not exist: '#{src}'") unless File.exists?(src)
      # see if the folder path exists
      # This top level test is much faster than testing all intermediate directories
      unless self.exists?( File.dirname(dst) )
        # Directory doesn't exist, make it
        dirs = File.dirname(dst).split('/')
        dirs.shift if dirs.first.empty?
        d = ''
        dirs.each do |dir|
          d << '/' + dir
          # directory is missing, create it
          unless self.exists?(d)
            begin
            connection.mkdir(d)
            rescue Net::FTPPermError => e
              raise "Unable to create directory: '#{d}'. " + e.to_s
            end
          end
        end
      end
      if block_given?
        connection.putbinaryfile( src, dst, chunksize, block )
      else
        connection.putbinaryfile( src, dst, chunksize )
      end
      last_ftp_command_ok?
    end


=begin
Download

Download a file from the server
=end
    def download( src, dst, &block )
      dst_folder = File.dirname(dst)
      raise ArgumentError.new("dst folder does not exist: '#{dst_folder}'") unless File.exists?( dst_folder )
      connection.chdir( File.dirname(src) )
      if block_given?
        connection.getbinaryfile( src, dst, chunksize, block )
      else
        connection.getbinaryfile( src, dst )
      end
      last_ftp_command_ok?
    end


    # deletes the file at the destination, cleans up the folders if empty
    def remove_file_and_clean_directories( path )
      # first, delete the file
      delete_file( path )
      # recursively remove any parent directories, but only if they are empty, stop if they are not
      remove_empty_folders_recursively( path )
    end


    # Deletes the file at the remote path
    def delete_file( path )
      # removes a file at path
      connection.delete( path )
      last_ftp_command_ok?
    end


    def remove_empty_folders_recursively( path )
      path = File.dirname(path)
      dirs = path.split('/')
      dirs.shift if dirs.first.empty?
      p = '/' + dirs.join('/')
      while self.empty?( p )
        begin
        connection.rmdir( p )
        rescue Net::FTPPermError => e
          raise ArgumentError.new("Unable to remove directory: '#{path}'; " + e.to_s)
        end
        # remove last path component
        dirs = dirs[0..-2]
        p = '/' + dirs.join('/')
      end
      true
    end


    # Check if file or directory exists
    def exists?( path )
      # directory
      if File.directory?(path)
        # if this cd's then it exists, if it fails, should return false
        connection.chdir( path )
      else
        connection.nlst(File.dirname(path)).include?( File.basename(path) )
      end
    end

    # Check if directory is empty
    def empty?( dir_path )
      connection.nlst( dir_path ).empty?
    end

=begin
Logout

Permits you to disconnect from the FTP session if it's still running. This allows you to manually control the out-bound connection. If you allow this class to be garbage collected, the connection will be severed. This allows you finer control. Any command that interacts with FTP will automatically issue a login.
=end
    def close
      if @connection
        @connection.close unless @connection.closed?
      end
      @connection = nil
    end


    # The default size
    def chunksize
      10_000_000 # 10 MB
    end


    :protected
    def connection
      # if closed, create and login if no connection exists or is closed
      if self.closed?
        @connection = Net::FTP.new(self.host)
				@connection.passive = true
        login
      end
      @connection
    end
    def connect
      login
    end
    def closed?
      return true if @connection.nil?
      begin
        return @connection.closed?
      rescue Net::FTPConnectionError => e
        return false
      end
    end
    def login
      connection.login( self.username, @password )
    end


    def last_ftp_command_ok?
      200 <= connection.last_response_code.to_i and connection.last_response_code.to_i < 300
    end
  end # FTP


=begin
HTTP Secure Progressive Link Generation

Creates URLs to access files stored at your company's BitGravity account.
=end
  class SecureUrl
    attr_reader :secret, :hostname, :company_id, :secure_paths
    def initialize( secret, hostname, company_id, secure_paths = nil )
      @secret = secret
      @hostname = hostname
      @company_id = company_id
      @secure_paths = []
      # The default secure path
      if secure_paths.nil?
        if self.cn?
          @secure_paths << '/' + company_id + '/secure'
        else
          @secure_paths << '/secure'
        end
      end
    end

=begin
URL: Returns the URL with the token for it

Arguments:
path [in]: (String) indicating the FTP path of the file uploaded.
opts[in]: (Hash) containing the flags to set on the URL and for the hash to reflect. Options are:
 e: Expiry in UTC sections since UTC 0. Setting to 0 indicates that expiry will be ignored. Do not use 0 for production
 a: Array of allowed county codes: ['US','CA']
 d: Array of disallowed country codes: ['US','CA']
 am: Array of allowed metro codes: [608,609]
 dm: Array of disallowed metro codes: [608,609]
 i: IP Address of client to allow. This is, typically, a good idea to include
 u: User-agent string. It's a "start_with" situation. BitGravity is looking for this parameter to start the browser portion of the UA string. For example, "Firefox" will match Mozilla Firefox browsers
=end
    def url( path, opts = {} )
      u = signature_plaintext( path, opts )
      h = OpenSSL::Digest::MD5.hexdigest(self.secret + u)
      ret = 'http://' + self.hostname
      p = path
      p = cn_adjusted_path( path ) if cn?
      ret << p
      ret << url_query_parameters( opts ) + '&h=' + h
      ret
    end


    :protected
    VALID_URL_OPTIONS = [:e,:a,:d,:am,:dm,:i,:u,:start,:end]
    def check_and_fix_url_options( opts )
      invalid_url_options = opts.keys.reject{|k| VALID_URL_OPTIONS.include?(k)}
      raise ArgumentError.new( "Unrecognized option(s) provided: [#{invalid_url_options.join(',')}]" ) unless invalid_url_options.empty?

      # EXPIRY TIME
      # If end is not specified, default to 0 (never expires)
      opts[:e] = 0 unless opts.has_key?(:e)
      if opts[:e].is_a?(Time)
        # convert to a number
        opts[:e] = opts[:e].utc.to_i
      end
      raise ArgumentError.new("Expiry (e) must be a number or a date, got '#{opts[:e].class.name}'") unless opts[:e].is_a?(Integer)

      raise ArgumentError.new("Allowed countries (a) must be an array of country codes: i.e. [US,CA]") if opts.has_key?(:a) and !opts[:a].is_a?(Array)
      raise ArgumentError.new("Disallowed countries (d) must be an array of country codes: i.e. [CD]") if opts.has_key?(:d) and !opts[:d].is_a?(Array)
      raise ArgumentError.new("Cannot use both allowed and disallowed countries at the same time, please pick one.") if opts.has_key?(:d) and opts.has_key?(:a)

      raise ArgumentError.new("Allowed metro codes (am) must be an array of metro codes: i.e. [807,828]") if opts.has_key?(:am) and !opts[:am].is_a?(Array)
      raise ArgumentError.new("Disallowed metro codes (dm) must be an array of metro codes: i.e. [609]") if opts.has_key?(:dm) and !opts[:dm].is_a?(Array)
      raise ArgumentError.new("Cannot use both allowed and disallowed metro codes at the same time, please pick one.") if opts.has_key?(:dm) and opts.has_key?(:am)

      if opts.has_key?(:start)
        raise ArgumentError.new("Progressive streaming start parameter must be a number") unless opts[:start].is_a?(Integer)
        raise ArgumentError.new("Progressive streaming start parameter must be greater than or equal to zero, got: #{opts[:start]}") unless opts[:start] >= 0
      end
      if opts.has_key?(:end)
        raise ArgumentError.new("Progressive streaming end parameter must be a number") unless opts[:end].is_a?(Integer)
        raise ArgumentError.new("Progressive streaming end parameter must be greater than zero, got: #{opts[:end]}") unless opts[:start] > 0
      end

      opts
    end


    def signature_plaintext( path, opts )
      # Confirmed with BG that we must always use the CN adjusted path, even if we
      # will not be outputting that CN adjusted path in the URL, as a matter of fact,
      # if you try to use the CN adjusted path on a non-CN hostname, you'll get a 404 as
      # the path is incorrect.
      cn_adjusted_path(path) + url_query_parameters( opts )
    end

    def cn_adjusted_path( path )
      '/' + self.company_id + path
    end


    def url_query_parameters( opts )
      opts = check_and_fix_url_options( opts )
      sig = '?e=' + opts[:e].to_s
      sig << '&a=' + opts[:a].join(',') if opts.has_key?(:a) and !opts[:a].nil?
      sig << '&d=' + opts[:d].join(',') if opts.has_key?(:d) and !opts[:d].nil?
      sig << '&am=' + opts[:am].join(',') if opts.has_key?(:am) and !opts[:am].nil?
      sig << '&dm=' + opts[:dm].join(',') if opts.has_key?(:dm) and !opts[:dm].nil?
      sig << '&i=' + opts[:i] if opts.has_key?(:i) and !opts[:i].nil?
      sig << '&u=' + opts[:u] if opts.has_key?(:u) and !opts[:u].nil?
      sig << '&start=' + opts[:start].to_s if opts.has_key?(:start) and !opts[:start].nil?
      sig << '&end=' + opts[:end].to_s if opts.has_key?(:end) and !opts[:end].nil?
      sig
    end


    # determines if hostname contains company id, if it doesn't, it's a CN (domain alias)
    def cn?
      !self.hostname.end_with?( '.cdn.bitgravity.com' )
    end


    def secure_url?( path )
      self.secure_paths.detect do |sp|
        path.start_with?(sp)
      end
    end
  end # HTTP

end
