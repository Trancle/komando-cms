#!/usr/bin/env ruby
#
# Install MMS
#
# We need lots of software!
%w(git rubygems apache2 postgresql-server-dev-8.4 libcurl4-openssl-dev apache2-prefork-dev libapr1-dev libaprutil1-dev).each do |package|
	puts "installing #{package}"
	`apt-get install -y #{package}`
end

# Gems
['liquid --VERSION 2.0.0','postgres --VERSION 0.7.9.2008.01.28', 'bundler'].each do |gem|
	puts "installing gem #{gem}"
	`gem install #{gem} --no-rdoc --no-ri`
end

# Install passenger
puts "Installing passenger"
`gem install passenger --no-rdoc --no-ri`

# Get the GEM Path
gem_path = `gem environment gempath`

# Install Apache modules for Phusion
puts "installing #{gem_path}/passenger-install-apache2-module"
`#{gem_path}/bin/passenger-install-apache2-module`

# Get the install to path
puts "Where do you want to install the application?"
vms_rails_root = gets.chomp

vms_user = 'www-data'
vms_group = 'www-data'

# Create the directory
`mkdir '#{vms_rails_root}'`
# Change permissions
`chown #{vms_user}:#{vms_group} '#{vms_rails_root}'`

# become the VMS user, cd to the directory
`su -c 'cd #{vms_rails_root}; git clone ssh://vms_repo@wojno.com/home/vms_repo/vms_backend' #{vms_user}`


