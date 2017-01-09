require File.dirname(__FILE__) + "/../lib/bitgravity.rb"
require File.dirname(__FILE__) + '/bit_gravity_ftp_helper.rb'
require 'yaml'
require 'rubygems'
require 'curb' # CUrl-RuBy (Rubygem)

TEST_DIR = '/secure/test-bit-gravity-gem'
FTP_CREDS = YAML.load_file( File.dirname(__FILE__) + '/config/test_ftp_credentials.yml' )
SECURE_SETTINGS = YAML.load_file( File.dirname(__FILE__) + '/config/test_secure_url.yml' )


describe BitGravity::SecureUrl do
  it "produces anticipated urls based on specific input data" do
    bg = BitGravity::SecureUrl.new( SECURE_SETTINGS['secret'], SECURE_SETTINGS['hostname'], SECURE_SETTINGS['company_id'], SECURE_SETTINGS['secure_urls'] )
    t = Time.utc( 2012, 1, 1, 0, 0, 0 ) # Jan 1, 2012 midnight UTC
    path_w_args = '/secure/this-is-a-test-path.txt?e=' + t.to_i.to_s
    exp = 'http://' + SECURE_SETTINGS['hostname'] + path_w_args + '&h=' + OpenSSL::Digest::MD5.hexdigest( SECURE_SETTINGS['secret'] + '/' + SECURE_SETTINGS['company_id'] + path_w_args )
    bg.url( '/secure/this-is-a-test-path.txt', :e => t.to_i ).should eql( exp )

    secret = SECURE_SETTINGS['secret']
    hostname = SECURE_SETTINGS['hostname']
    path_w_args = '/secure/this-is-a-test-path.txt?e=0'
    exp = 'http://' + hostname + path_w_args + '&h=' + OpenSSL::Digest::MD5.hexdigest( secret + '/' + SECURE_SETTINGS['company_id'] + path_w_args )
    bg.url( '/secure/this-is-a-test-path.txt', :e => 0 ).should eql( exp )


    # From the support document: BG_Secure_Access_API.pdf 2012-12-01 page 3
    bg =  BitGravity::SecureUrl.new( 'mySecret', 'bitcast-g.bitgravity.com', 'acmecompany', ['/content'] )
    bg.url( '/content/protected.flv', :e => 1182665958, :a => ['US'] ).should eql( "http://bitcast-g.bitgravity.com/acmecompany/content/protected.flv?e=1182665958&a=US&h=ec41f550878f45d9724776761d6ac416" )
  end

  it "upload file and verify that it can be downloaded" do

    bg = BitGravity::SecureUrl.new( SECURE_SETTINGS['secret'], SECURE_SETTINGS['hostname'], SECURE_SETTINGS['company_id'], SECURE_SETTINGS['secure_urls'] )
    ftp = create_bgftp

    # Upload the test file into place
    url = bg.url( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt', :e => 0 )
    ftp.upload(File.dirname(__FILE__) + '/fixtures/test-file.txt', TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' )

    # download the file using the URL generated to make sure that it works.
    remote = nil
    curl = Curl::Easy.new(url)
    curl.follow_location = true # BitGravity uses redirection. The link you request might not be the one that responds the first time
    curl.perform
    remote = curl.body_str


    # Compare the downloaded file, with the uploaded file
    local = File.open(File.dirname(__FILE__) + '/fixtures/test-file.txt','r').read
    local.should eql(remote)


    ftp.remove_file_and_clean_directories( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' )
  end

  it "download a file with an expiration in the future" do

    bg = BitGravity::SecureUrl.new( SECURE_SETTINGS['secret'], SECURE_SETTINGS['hostname'], SECURE_SETTINGS['company_id'], SECURE_SETTINGS['secure_urls'] )
    ftp = create_bgftp

    # Upload the test file into place
    url = bg.url( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt', :e => Time.now.utc + 30 )
    ftp.upload(File.dirname(__FILE__) + '/fixtures/test-file.txt', TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' )

    # download the file using the URL generated to make sure that it works.
    remote = nil
    curl = Curl::Easy.new(url)
    curl.follow_location = true # BitGravity uses redirection. The link you request might not be the one that responds the first time
    curl.perform
    remote = curl.body_str


    # Compare the downloaded file, with the uploaded file
    local = File.open(File.dirname(__FILE__) + '/fixtures/test-file.txt','r').read
    local.should eql(remote)


    ftp.remove_file_and_clean_directories( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' )
  end


  it "restrict download by IP address" do

    bg = BitGravity::SecureUrl.new( SECURE_SETTINGS['secret'], SECURE_SETTINGS['hostname'], SECURE_SETTINGS['company_id'], SECURE_SETTINGS['secure_urls'] )
    ftp = create_bgftp

    # Upload the test file into place
    url = bg.url( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt', :e => Time.now.utc + 30, :i => SECURE_SETTINGS['client_ip_address'] )
    ftp.upload(File.dirname(__FILE__) + '/fixtures/test-file.txt', TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' )

    # download the file using the URL generated to make sure that it works.
    remote = nil
    curl = Curl::Easy.new(url)
    curl.follow_location = true # BitGravity uses redirection. The link you request might not be the one that responds the first time
    curl.perform
    remote = curl.body_str


    # Compare the downloaded file, with the uploaded file
    local = File.open(File.dirname(__FILE__) + '/fixtures/test-file.txt','r').read
    local.should eql(remote)


    ftp.remove_file_and_clean_directories( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' )
  end

end # BitGravity::SecureUrl
