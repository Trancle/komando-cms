require File.dirname(__FILE__) + "/../lib/bitgravity.rb"
require File.dirname(__FILE__) + '/bit_gravity_ftp_helper.rb'
require 'yaml'

TEST_DIR = '/test-bit-gravity-gem'
FTP_CREDS = YAML.load_file( File.dirname(__FILE__) + '/config/test_ftp_credentials.yml' )

describe BitGravity::Ftp do
  it "tests for file non-existence" do
    ftp = create_bgftp
    ftp.exists?(TEST_DIR + '/file-that-should-not-exist.txt').should be_false
    ftp.close
  end

  it "tests for directory non-existence" do
    ftp = create_bgftp
    ftp.exists?(TEST_DIR + '/folder-that-should-not-exist').should be_false
    ftp.close
  end


  it "tests for directory existence" do
    f = create_test_folder
    f.mkdir( TEST_DIR + '/free' )
    f.mkdir( TEST_DIR + '/secure' )

    ftp = create_bgftp
    ftp.exists?( TEST_DIR ).should be_true
    ftp.exists?( TEST_DIR + '/free' ).should be_true
    ftp.exists?( TEST_DIR + '/secure' ).should be_true

    f.rmdir( TEST_DIR + '/secure' )
    f.rmdir( TEST_DIR + '/free' )
    remove_test_folder f
    ftp.close
    f.close
  end

  it "tests for file existence" do
    f = create_test_folder
    f.chdir( TEST_DIR )
    f.puttextfile( File.dirname(__FILE__) + '/fixtures/test-file.txt')
    ftp = create_bgftp
    # test if file is there
    ftp.exists?( TEST_DIR + '/test-file.txt' ).should be_true

    # clean up
    f.delete( TEST_DIR + '/test-file.txt' )
    remove_test_folder f
    ftp.close
    f.close
  end

  it "tests upload" do
    f = create_test_folder
    ftp = create_bgftp
    ftp.upload( File.dirname(__FILE__) + '/fixtures/test-file.txt', TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' ).should be_true
    # test if file is there
    ftp.exists?( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' ).should be_true

    # clean up
    f.delete( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' )
    f.rmdir( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff' )
    f.rmdir( TEST_DIR + '/aaa/bbb/ccc/ddd/eee' )
    f.rmdir( TEST_DIR + '/aaa/bbb/ccc/ddd' )
    f.rmdir( TEST_DIR + '/aaa/bbb/ccc' )
    f.rmdir( TEST_DIR + '/aaa/bbb' )
    f.rmdir( TEST_DIR + '/aaa' )
    remove_test_folder f
    ftp.close
    f.close
  end

  it "tests removal and clean up of uploaded file and folders" do
    f = create_test_folder
    ftp = create_bgftp
    ftp.upload( File.dirname(__FILE__) + '/fixtures/test-file.txt', TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' ).should be_true
    # test if file is there
    ftp.exists?( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' ).should be_true
    ftp.remove_file_and_clean_directories( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' )
    ftp.exists?( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff/test-file.txt' ).should be_false
    ftp.exists?( TEST_DIR + '/aaa/bbb/ccc/ddd/eee/fff' ).should be_false
    ftp.exists?( TEST_DIR + '/aaa/bbb/ccc/ddd/eee' ).should be_false
    ftp.exists?( TEST_DIR + '/aaa/bbb/ccc/ddd' ).should be_false
    ftp.exists?( TEST_DIR + '/aaa/bbb/ccc' ).should be_false
    ftp.exists?( TEST_DIR + '/aaa/bbb' ).should be_false
    ftp.exists?( TEST_DIR + '/aaa' ).should be_false
    ftp.exists?( TEST_DIR ).should be_false

    # clean up
    # done by test
    #remove_test_folder f
    ftp.close
    f.close
  end


end # BitGravity::Ftp