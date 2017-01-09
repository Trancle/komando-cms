namespace :app do
	desc "Creates the default page layouts"
	task :create_page_layouts => :environment do

		PageLayout.create_default_layouts_for_home_show_watch

	end#task :create_page_layouts
end#namespace :app
