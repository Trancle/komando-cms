require 'rubygems'
gem 'activerecord', '=2.3.14'
require 'active_record'
require 'active_record/fixtures'
ActiveRecord::Migration.verbose = false


File.unlink('active_record_test.db') if File.exists?( 'active_record_test.db' )
ActiveRecord::Base.establish_connection( {
		:adapter => 'sqlite3',
		:database => 'active_record_test.db'
} )


require File.dirname(__FILE__) + '/../fixtures/schema.rb'
