namespace :app do
desc "Create blank directories to prepare for application run"
task(:create_initial_file_structure) do

dirs = ['private','private/pages','private/videos','tmp','log','tmp/pids','tmp/sockets','tmp/sessions','tmp/cache','public/managed_file_resource_images']

dirs.each do |dir|
	f = RAILS_ROOT + "/" + dir
	Dir.mkdir( f ) unless File.exists?f
end

end#task :create_initial_file_structure
end#namespace :app
