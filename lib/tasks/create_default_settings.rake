namespace :app do
	desc "Creates all the settings in Settings"
	task :create_default_settings => :environment do

		Setting.create_settings

	end#task :create_default_settings
end#namespace :app
