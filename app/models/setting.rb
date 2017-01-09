class Setting < ActiveRecord::Base

	validates_presence_of :name
	validates_length_of :name, :allow_nil => true, :in => 1..256

	validates_length_of :description, :allow_nil => true, :allow_blank => true, :maximum => 1024
	validates_length_of :programmatic_name, :in => 1..1024


	# loads all settings at once in one DB call, saves them for future use in same request
	# cache does NOT survive between requests. Use sweepers and rails caching for that. This
	# simply reduces first time generation load for the global site settings
	def self.[]( name )
		begin
			@@settings_cache
		rescue NameError => s
			@@settings_cache = Setting.find( :all, :select => 'type, programmatic_name, value', :readonly => true )
		end

		r = @@settings_cache.find{|s| s.programmatic_name.eql?name}
		if r.nil?
			Setting.find_by_programmatic_name( name )
		else
			r
		end
	end



	VALID_SUBCLASSES = %w(SettingPositiveInteger SettingInteger SettingFloat SettingString SettingDate SettingBoolean SettingPositiveNonZeroInteger)
	def self.valid_subclass?( t )
		VALID_SUBCLASSES.include?(t)
	end

	def friendly_type_name
		self.class.name.underscore.humanize
	end

	def store_previous_value
		self.write_attribute( :previous_value, self.read_attribute( :value ) ) unless self.previous_value.eql?self.value
	end

	def self.create_settings_v1
		ret = []

		ret << SettingString.new( :name => 'Site global title', :programmatic_name => "#{protected_programmatic_prefix}-site-head-title", :description => 'This is the title for the site should appear on the top of every page as the HTML title tag. You must, of course, include this setting in the layout for it to appear.', :value => 'VMS' )
		ret << SettingString.new( :name => 'Site global title separator', :programmatic_name => "#{protected_programmatic_prefix}-site-head-title-separator", :description => 'This separator appears separates the title of the site and sub-titles in the HTML title tag. You must, of course, include this setting in the layout for it to appear.', :value => '- ' )
		ret << SettingString.new( :name => 'Site global keywords', :programmatic_name => "#{protected_programmatic_prefix}-site-head-meta-keywords", :description => 'These keywords appear on every page and are inserted before page-specific keywords. Remember, keywords are not only words, but can be multiple words. Keywords are separated by commas (,). These appear in the <meta name="keywords"...> HTML tag.' )
		ret << SettingString.new( :name => 'Site global description', :programmatic_name => "#{protected_programmatic_prefix}-site-head-meta-description", :description => 'This description will appear on every page and is inserted before page-specific description. This can be only plain text. No HTML. This will appear in the <meta name="description"...> HTML tag.' )
		ret << SettingPositiveInteger.new( :name => 'Login "Remember Me" duration', :programmatic_name => "#{protected_programmatic_prefix}-remember-me-days", :description => 'This setting sets how long the cookies will persist when the user selects "Remember me" when logging in. Setting to 0 means that the cookie will never expire. Setting it to a positive integer will indicate that the cookie will expire that many days after the login first occured.', :value => 14 )
		ret << SettingString.new( :name => 'Google Analytics Account ID', :programmatic_name => "#{protected_programmatic_prefix}-google-analytics-account-id", :description => 'This account ID is used by google analytics insertion code. When the insertion code appears, it will automatically be populated with this account ID. If none is provided, the tracking code will NOT be inserted.' )
		ret << SettingPositiveNonZeroInteger.new( :name => 'Items per page (administration)', :programmatic_name => "#{protected_programmatic_prefix}-items-per-page", :description => 'The default number of items that will be listed for any given administrator list. Items will be paginated such that this is the maximum number of items that will be displayed each page. This can be overridden by individual users.', :value => 20 )
		ret << SettingPositiveNonZeroInteger.new( :name => 'Search results per page (search)', :programmatic_name => "#{protected_programmatic_prefix}-search-results-per-page", :description => 'The default number of items that will be listed when a search is performed. More results puts a greater strain on the system.', :value => 20 )
		ret << SettingString.new( :name => 'Premium content purchase URL', :programmatic_name => "#{protected_programmatic_prefix}-premium-content-purchase-url", :description => 'A url to which the user will be redirected if he or she attempts to watch protected content. Ideally, this is a one-off page that entices the user to purchase a subscription. If left blank, this will render "private/pages/premium_purchase_required.erb"', :value => '' )
		ret << SettingPositiveInteger.new( :name => 'User comment cool-down" duration', :programmatic_name => "#{protected_programmatic_prefix}-user-comment-cool-down-time", :description => 'The number of seconds that must elapse between a single user posting two comments. This should prevent extremely abusive spamming. A value of 0 indicates that there is NO cool-down period.', :value => 30 )
		ret << SettingBoolean.new( :name => 'User input enabled (globally)', :programmatic_name => "#{protected_programmatic_prefix}-user-input-enabled", :description => 'This setting globally (among all shows and episodes) determines if users of any flavor (except administrators) are able to add information to episodes (such as tags or comments/discussions). If true, user-input is accepted. If false, all user input is rejected, even if it\'s valid.', :value => true )
		ret << SettingPositiveInteger.new( :name => 'Maximum visible tags per episode', :programmatic_name => "#{protected_programmatic_prefix}-maximum-visible-tags-per-episode", :description => 'The maximum number of tags that will be visible on a the public episode page (the viewer). More can exist, but only these top tags will appear.', :value => 20 )
		ret << SettingPositiveNonZeroInteger.new( :name => 'New video deletion grace period (days)', :programmatic_name => "#{protected_programmatic_prefix}-new-video-deletion-grace-period-days", :description => 'Every so often, there is a process that runs and removes video files that are no longer referenced or will never appear again based on the show and episode schedules. However, when a new file is uploaded, since it is unreferenced and has no associate episode or show, it will be eligable for deletion. This is probably not what you wanted because you uploaded that file. This value is the number of days that a new video file will be exempted from deletion. Therefore, all files will exist on this system and the CDN for at least this many days. The minimum is 1 day.', :value => 14 )
		ret << SettingPositiveInteger.new( :name => 'Video deletion grace period (days)', :programmatic_name => "#{protected_programmatic_prefix}-video-deletion-grace-period", :description => 'Every so often, there is a process that runs and removes video files that are no longer referenced or will never appear again based on the show and episode schedules. However, it is understood that scheduling mistakes will be made. This feature will prevent the file deleting process from occuring for the specified number of days (0 day delay is OK, in this case, the file will be deleted as soon as it expires and the process runs). This is good for doing an "emergency" schedule extension in the event you need to leave the file up longer. A good default is a week (7 days)', :value => 7 )
		ret << SettingString.new( :name => 'Layout stylesheet: Home', :programmatic_name => "stylesheet-url-for-layout-home", :description => 'This is the stylesheet that will be linked to on the home page layout. It is optional and, if no value is specified (or this value is deleted), the generic public stylesheet will be used.', :value => '' )
		ret << SettingString.new( :name => 'Layout stylesheet: Show', :programmatic_name => "stylesheet-url-for-layout-show", :description => 'This is the stylesheet that will be linked to on the show page layout. It is optional and, if no value is specified (or this value is deleted), the generic public stylesheet will be used.', :value => '' )
		ret << SettingString.new( :name => 'Layout stylesheet Watch', :programmatic_name => "stylesheet-url-for-layout-watch", :description => 'This is the stylesheet that will be linked to on the watch page layout. It is optional and, if no value is specified (or this value is deleted), the generic public stylesheet will be used.', :value => '' )
		ret << SettingString.new( :name => 'Layout stylesheet: Auth', :programmatic_name => "stylesheet-url-for-layout-auth", :description => 'This is the stylesheet that will be linked to on the auth page layout. It is optional and, if no value is specified (or this value is deleted), the generic public stylesheet will be used.', :value => '' )
		ret << SettingString.new( :name => 'Layout stylesheet: Search', :programmatic_name => "stylesheet-url-for-layout-search", :description => 'This is the stylesheet that will be linked to on the search page layout. It is optional and, if no value is specified (or this value is deleted), the generic public stylesheet will be used.', :value => '' )
		ret << SettingString.new( :name => 'Layout stylesheet: Premium Required', :programmatic_name => "stylesheet-url-for-layout-premium-required", :description => 'This is the stylesheet that will be linked to on the premium required page layout. It is optional and, if no value is specified (or this value is deleted), the generic public stylesheet will be used.', :value => '' )
		ret << SettingString.new( :name => 'Render Partial: Header', :programmatic_name => "#{protected_programmatic_prefix}-render-partial-header", :description => 'The header to be rendered in every layout. This should, typically, exist as private/pages/_header.erb', :value => 'app/views/layouts/_header.erb' )
		ret << SettingString.new( :name => 'Render Partial: Footer', :programmatic_name => "#{protected_programmatic_prefix}-render-partial-footer", :description => 'The footer to be rendered in every layout. This should, typically, exist as private/pages/_footer.erb', :value => 'app/views/layouts/_footer.erb' )
		ret << SettingPositiveInteger.new( :name => 'Number of comments visible at a time for an episode', :programmatic_name => "#{protected_programmatic_prefix}-visible-episode-comment-count", :description => 'This is the number of comments that are allowed to appear on a comment page at any given time. Only the latest comments will appear. This value is effective for the watch-viewer page. Specifying zero means that comments will never show up.', :value => 100 )
		ret << SettingString.new( :name => 'IPs allowed to preview without login', :programmatic_name => "#{protected_programmatic_prefix}-preview-ips", :description => 'Any system using an IP in this range or set of ranges will be allowed to access future content without a login as though it were live.', :value => '' )
		ret
	end

	def self.create_settings_v2
		[SettingString.new( :name => 'IPs allowed to preview without login', :programmatic_name => "#{protected_programmatic_prefix}-preview-ips", :description => 'Any system using an IP in this range or set of ranges will be allowed to access future content without a login as though it were live.', :value => '' )]
	end

	def self.create_settings
		create_settings_v1.each {|s| begin; s.save; rescue; end }
		create_settings_v2.each {|s| begin; s.save; rescue; end }
	end

	def self.protected_programmatic_prefix
		'vms-protected'
	end

	def protected?
		(self.programmatic_name || '' ).match( /\A#{self.class.protected_programmatic_prefix}/ )
	end

# blank out the setting
	def blank_out
		self.write_attribute(:value, nil )
	end
end
