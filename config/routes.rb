ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

	map.home '/', :controller => 'home', :action => 'home'



  # Show listing
  map.connect 'shows', :controller => 'shows', :action => 'index'
  map.connect 'shows.:format', :controller => 'shows', :action => 'index'


	map.connect 'watch/next', :controller => 'watch', :action => 'next'
	map.connect 'watch/comments/:id', :controller => 'watch', :action => 'comments'
#map.connect 'watch/:id', :controller => 'watch', :action => 'viewer'
	map.connect 'watch/:id/:title', :controller => 'watch', :action => 'viewer'
	map.connect 'watch/:id/:title.:format', :controller => 'watch', :action => 'viewer'
	map.connect 'watch/:id/:title/*extra', :controller => 'watch', :action => 'viewer'
  map.connect 'watch/:id.:format', :controller => 'watch', :action => 'viewer'
	map.connect 'watch/:id', :controller => 'watch', :action => 'viewer'

# commenting
	map.episode_comment 'comment/:action/:id', :controller => 'comment'
	map.connect 'comment/:action/:id.:format', :controller => 'comment'


	map.connect 'cms', :controller => 'cms/dashboard'
	map.connect 'cms/shows/:action/:id', :controller => 'cms/shows'
	map.connect 'cms/episodes/:action/:id', :controller => 'cms/episodes'
	map.connect 'cms/episode_parts/:action/:id', :controller => 'cms/episode_parts'
  map.connect 'cms/episode_tags/:action/:id.:format', :controller => 'cms/episode_tags'
  map.connect 'cms/episode_tags/:action/:id', :controller => 'cms/episode_tags'
  map.connect 'cms/episode_tags/:action.:format', :controller => 'cms/episode_tags'
  map.connect 'cms/show_dl_episodes/:action/:id.:format', :controller => 'cms/show_dl_episodes'
  map.connect 'cms/show_dl_episodes/:action/:id', :controller => 'cms/show_dl_episodes'
  map.connect 'cms/show_dl_episodes/:action.:format', :controller => 'cms/show_dl_episodes'
  map.connect 'cms/home_page_blocks/:action/:id.:format', :controller => 'cms/home_page_blocks'
  map.connect 'cms/home_page_blocks/:action/:id', :controller => 'cms/home_page_blocks'
  map.connect 'cms/home_page_blocks/:action.:format', :controller => 'cms/home_page_blocks'
	map.connect 'cms/show_categories/:action/:id', :controller => 'cms/show_categories'
	map.connect 'cms/user_input_blacklists/:action/:id', :controller => 'cms/user_input_blacklists'
	map.connect 'cms/analytics/:action/:id', :controller => 'cms/analytics'
	map.connect 'cms/content/:action/:id', :controller => 'cms/content'
	map.connect 'cms/content/:action.:format', :controller => 'cms/content'
	map.connect 'cms/content/:action/:id.:format', :controller => 'cms/content'
	map.connect 'cms/download/:action/:id', :controller => 'cms/download'
	map.connect 'cms/public_images/:action/:id', :controller => 'cms/public_images'
	map.connect 'cms/public_images/:action.:format', :controller => 'cms/public_images'
	map.connect 'cms/public_images/:action/:id.:format', :controller => 'cms/public_images'
	map.connect 'cms/ad_insertion_locations/:action/:id', :controller => 'cms/ad_insertion_locations'
	map.connect 'cms/related_shows/:action/:id', :controller => 'cms/related_shows'
	map.connect 'cms/episode_comments/:action/:id', :controller => 'cms/episode_comments'
	map.connect 'cms/recent_comments/:action/:id', :controller => 'cms/recent_comments'
	map.connect 'cms/flagged_comments/:action/:id', :controller => 'cms/flagged_comments'
	map.connect 'cms/page_layouts/:action/:id', :controller => 'cms/page_layouts'
	map.connect 'cms/dashboard/:action/:id', :controller => 'cms/dashboard'

  # Sample resource route within a namespace:
	 map.namespace :cms do |cms|
		 # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
		 cms.resources :shows, :episodes, :episode_parts, :episode_tags, :show_tags, :show_categories, :user_input_blacklists, :analytics, :content, :dashboard, :download, :ad_insertion_locations, :related_shows, :episode_comments, :flagged_comments, :page_layouts, :recent_comments
	 end


	map.connect 'admin', :controller => 'admin/dashboard'
	map.connect 'admin/users/:action/:id', :controller => 'admin/users'
	map.connect 'admin/roles/:action/:id', :controller => 'admin/roles'
	map.connect 'admin/role_rights/:action/:id', :controller => 'admin/role_rights'
	map.connect 'admin/user_input_bans/:action/:id', :controller => 'admin/user_input_bans'
	map.connect 'admin/settings/:action/:id', :controller => 'admin/settings'
	map.connect 'admin/maintenance/:action/:id', :controller => 'admin/maintenance'
	map.connect 'admin/task_runner_tasks/:action/:id', :controller => 'admin/task_runner_tasks'
	map.connect 'admin/dashboard/:action/:id', :controller => 'admin/dashboard'

	 map.namespace :admin do |admin|
		 # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
		 admin.resources :users, :roles, :role_rights, :user_input_bans, :dashboard, :settings, :maintenance, :task_runner_tasks
	 end

	map.connect 'ads', :controller => 'ads/dashboard'
	map.connect 'ads/campaigns/:action/:id', :controller => 'ads/campaigns'
	map.connect 'ads/advertisers/:action/:id', :controller => 'ads/advertisers'
	map.connect 'ads/spots/:action/:id', :controller => 'ads/spots'
	map.connect 'ads/impressions/:action/:id', :controller => 'ads/impressions'
	map.connect 'ads/clickthroughs/:action/:id', :controller => 'ads/clickthroughs'
	map.connect 'ads/exclusivities/:action/:id', :controller => 'ads/exclusivities'
	map.connect 'ads/schedules/:action/:id', :controller => 'ads/schedules'
	map.connect 'ads/insertion_points/:action/:id', :controller => 'ads/insertion_points'
	map.connect 'ads/dashboard/:action/:id', :controller => 'ads/dashboard'
	map.connect 'ads/dispositions/:action/:id', :controller => 'ads/dispositions'

	 map.namespace :ads do |admin|
		 # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
		 admin.resources :campaigns, :advertisers, :spots, :impressions, :clickthroughs, :schedules, :insertion_points, :dashboard, :dispositions, :exclusivities
	 end

	map.connect 'content/hosted/:action/:id', :controller => 'content/hosted'

	 map.namespace :content do |admin|
		 # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
		 admin.resources :hosted
	 end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
	map.connect 'auth', :controller => 'auth', :action => 'index'
	map.connect 'auth/login', :controller => 'auth', :action => 'login'
	map.connect 'auth/login.:format', :controller => 'auth', :action => 'login'
	map.connect 'auth/logout', :controller => 'auth', :action => 'logout'
	map.connect 'auth/logout.:format', :controller => 'auth', :action => 'logout'

  map.connect 'auth/admin',  :controller => 'auth', :action => 'admin'
  map.connect 'auth/cas_authenticate',  :controller => 'auth', :action => 'cas_authenticate'



	map.connect 'sitemap.xml', :controller => 'sitemap', :action => 'index'
	map.connect 'tag/*terms', :controller => 'tag', :action => 'as_search'

	map.connect 'search', :controller => 'search', :action => 'index'
	map.connect 'search/find', :controller => 'search', :action => 'find'
	map.connect 'search/:term', :controller => 'search', :action => 'find'

	map.connect 'api/record_email', :controller => 'api', :action => 'record_email'


	map.connect ':title', :controller => 'shows', :action => 'episodes'
	map.connect ':title.:format', :controller => 'shows', :action => 'episodes'
	map.connect ':title/latest', :controller => 'shows', :action => 'latest'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

	# check route aliases/404 next, if no alias, then 404 with search
	map.connect '*path', :controller => 'search', :action => 'find'
end
