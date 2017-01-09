class AddCustomSectionHeadersPremiumTemplate < ActiveRecord::Migration

	ActionView::Helpers
  def self.up

		# creates a new page layout for the global head tag include

		default_layout = ''

premium_page_layout = <<EOD
<p>Sorry, a valid login is required to view this page. Please login to watch this episode.</p>

<form action="/auth/login" method="post">
{{login_token}}
{{redirect_back_after_login}}
<p><label for="username">E-mail Address</label> <input id="username" type="text" name="username" value="" /></p>
<p><label for="password">Password</label> <input id="password" type="password" name="password" value="" /></p>
<p><label for="remember_me">Remember me?</label> <input id="remember_me" type="checkbox" name="remember_me" value="1" /></p>
<p><button>login</button></p>
</form>
<script type="text/javascript">
$('#username').focus();
</script>
EOD


		build = [
			{ :programmatic_name => 'watch-header-include',
			:name => 'Watch Page Header head-tag-include',
			:description => 'This template is inserted into every watch page (/watch/*) inside the head-tag just below the global head-tag includes' },
			{ :programmatic_name => 'shows-episodes-header-include',
			:name => 'Show Page Header head-tag-include',
			:description => 'This template is inserted into every show page (/SHOW-NAME) inside the head-tag just below the global head-tag includes' },
			{ :programmatic_name => 'home-header-include',
			:name => 'Home Page Header head-tag-include',
			:description => 'This template is inserted into the home page (/) inside the head-tag just below the global head-tag includes' },
			{ :programmatic_name => 'search-header-include',
			:name => 'Search Page Header head-tag-include',
			:description => 'This template is inserted into the search page (/search?q=*) inside the head-tag just below the global head-tag includes' },
			{ :programmatic_name => 'auth-header-include',
			:name => 'Auth Page Header head-tag-include',
			:description => 'This template is inserted into the login page (/auth) inside the head-tag just below the global head-tag includes' },
			{ :programmatic_name => 'premium-purchase-required',
			:name => 'Premium Purchase Required Page',
			:description => 'This content is shown instead of a watch page if the episode is premium (not free) and the user is not permitted to view the episode (not logged in or insufficient account privilege)',
			:default_layout => premium_page_layout },
			{ :programmatic_name => 'premium-purchase-required-header-include',
			:name => 'Premium Purchase Required Header head-tag-include',
			:description => 'This template is inserted into the premium-purchase-required page (/watch/* pages that required authentication and authorization) inside the head-tag just below the global head-tag includes' }
		]


		transaction do
			build.each do |settings|
				unless PageLayout.exists?( { :programmatic_name => settings[:programmatic_name] } )
					pl = PageLayout.new(  )
					pl.name = settings[:name]
					pl.programmatic_name = settings[:programmatic_name]
					pl.description = settings[:description]
					pl.save
					plv = pl.make_first_version()
					plv.layout = settings[:default_layout] || ''
					plv.version_comment = "Initial, generated version"
					plv.version_stub_id = pl.id
					plv.editor_id = 0
					raise plv.errors.full_messages.join(', ') unless plv.save

					dr = PageLayoutScheduleDateRange.new
					dr.exclusivity_id = pl.id
					dr.save
					pl.scheduled_version_schedule_version_with_range( plv, dr )
				end
			end 
		end
  end

  def self.down
		%w(watch-header-include shows-episodes-header-include home-header-include search-header-include auth-header-include premium-purchase-required premium-purchase-required-header-include).each do |pn|
		PageLayout.find_by_programmatic_name( pn ).destroy
		end
  end
end
