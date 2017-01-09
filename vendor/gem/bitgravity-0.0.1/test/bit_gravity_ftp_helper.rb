
def create_bgftp
  BitGravity::Ftp.new( FTP_CREDS['host'], FTP_CREDS['username'], FTP_CREDS['password'] )
end
def create_test_folder
  f = Net::FTP.new( FTP_CREDS['host'] )
  f.login( FTP_CREDS['username'], FTP_CREDS['password'] )
  f.mkdir( TEST_DIR )
  f
end
def remove_test_folder( f )
  f.rmdir( TEST_DIR )
end