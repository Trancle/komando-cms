class PageLayout < ActiveRecord::Base
	include CW::ActsAs::Versioned::Stub
	def self.scheduled_version_cw_mu_ex_date_range_set_klass; "PageLayoutScheduleDateRangeSet".constantize; end
	def self.scheduled_version_cw_mu_ex_date_range_range_klass; "PageLayoutScheduleDateRange".constantize; end
	def self.scheduled_version_klass; "PageLayoutSchedule".constantize; end
	def self.versioned_model_klass; "PageLayoutVersion".constantize; end
	include CW::ScheduledVersion::Stub
	
	has_many :page_layout_versions, :foreign_key => :version_stub_id, :dependent => :destroy

	validates_length_of :name, :in => 1..256
	attr_readonly :programmatic_name
	validates_uniqueness_of :programmatic_name


	def self.create_default_layouts_for_home_show_watch
		transaction do
			unless PageLayout.exists?( { :programmatic_name => 'home-home-page' } )
				home = PageLayout.new(  )
				home.name = 'Home Page'
				home.programmatic_name = 'home-home-page'
				home.description = <<EOD
<p>This is the home page of the site. You have a few programmatic options:</p>
<dl>
	<dt>show_version</dt>
	<dd>The show object of this episode</dd>

	<dt>episode</dt>
	<dd>The episode object</dd>

	<dt>player</dt>
	<dd>The player for the episode</dd>

	<dt>comments</dt>
	<dd>The comments and means to create comments for this episode</dd>
</dl>
EOD
				home.save
				homev = home.make_first_version()
				homev.layout = '<p>Default Home Layout</p>'
				homev.version_comment = "Initial, generated version"
				homev.version_stub_id = home.id
				homev.editor_id = 0
				raise homev.errors.full_messages.join(', ') unless homev.save

				dr = PageLayoutScheduleDateRange.new
				dr.exclusivity_id = home.id
				dr.save
				home.scheduled_version_schedule_version_with_range( homev, dr )
			end
			

			unless PageLayout.exists?( { :programmatic_name => 'shows-episodes-page' } )
				shows = PageLayout.new(  )
				shows.name = 'Episodes in show page'
				shows.programmatic_name = 'shows-episodes-page'
				shows.save
				showsv = shows.make_first_version()
				showsv.layout = '<p>Default Show Layout</p>'
				showsv.version_comment = "Initial, generated version"
				showsv.version_stub_id = shows.id
				showsv.editor_id = 0
				raise showsv.errors.full_messages.join(', ') unless showsv.save

				dr = PageLayoutScheduleDateRange.new
				dr.exclusivity_id = shows.id
				dr.save
				shows.scheduled_version_schedule_version_with_range( showsv, dr )
			end


			unless PageLayout.exists?( { :programmatic_name => 'watch-viewer-page' } )
				watch = PageLayout.new(  )
				watch.name = 'Watch viewer page'
				watch.programmatic_name = 'watch-viewer-page'
				watch.save
				watchv = watch.make_first_version()
				watchv.layout = '<h1>{{ episode.title }}</h1>{{ player }} <h2>Comments</h2> {{ comments }}'
				watchv.version_comment = "Initial, generated version"
				watchv.version_stub_id = watch.id
				watchv.editor_id = 0
				raise watchv.errors.full_messages.join(', ') unless watchv.save

				dr = PageLayoutScheduleDateRange.new
				dr.exclusivity_id = watch.id
				dr.save
				watch.scheduled_version_schedule_version_with_range( watchv, dr )
			end


			unless PageLayout.exists?(  { :programmatic_name => 'episode-comment' } )
				com = PageLayout.new(  )
				com.programmatic_name = 'episode-comment'
				com.name = 'Episode comment'
				com.save
				comv = com.make_first_version()
				comv.layout = <<EOD
<p>Comments here</p>
EOD
				comv.version_comment = "Initial, generated version"
				comv.version_stub_id = com.id
				comv.editor_id = 0
				raise comv.errors.full_messages.join(', ') unless comv.save

				dr = PageLayoutScheduleDateRange.new
				dr.exclusivity_id = com.id
				dr.save
				com.scheduled_version_schedule_version_with_range( comv, dr )
			end



			unless PageLayout.exists?( { :programmatic_name => 'search-find-page' } )
				s = PageLayout.new(  )
				s.programmatic_name = 'search-find-page'
				s.name = 'Search Result'
				raise s.errors.full_messages.join(', ') unless s.save
				sv = s.make_first_version()
				sv.layout = <<EOD
<p>Search Result</p>
EOD
				sv.version_comment = "Initial, generated version"
				sv.version_stub_id = s.id
				sv.editor_id = 0
				raise sv.errors.full_messages.join(', ') unless sv.save

				dr = PageLayoutScheduleDateRange.new
				dr.exclusivity_id = s.id
				dr.save
				s.scheduled_version_schedule_version_with_range( sv, dr )
			end



			unless PageLayout.exists?(  { :programmatic_name => 'auth-cannot-page' } )
				com = PageLayout.new(  )
				com.programmatic_name = 'auth-cannot-page'
				com.name = 'Cannot login due to account error'
				com.save
				comv = com.make_first_version()
				comv.layout = <<EOD
<h1>Cannot login</h1>

<p>We're sorry. There is a temporary situation in which we are unable to authenticate you. Please be patient a little while longer until this issue is resolved. Thanks!</p>
EOD
				comv.version_comment = "Initial, generated version"
				comv.version_stub_id = com.id
				comv.editor_id = 0
				raise comv.errors.full_messages.join(', ') unless comv.save

				dr = PageLayoutScheduleDateRange.new
				dr.exclusivity_id = com.id
				dr.save
				com.scheduled_version_schedule_version_with_range( comv, dr )
			end






			unless PageLayout.exists?(  { :programmatic_name => 'footer-include' } )
				com = PageLayout.new(  )
				com.programmatic_name = 'footer-include'
				com.name = 'Global footer that will appear on every content page'
				com.save
				comv = com.make_first_version()
				comv.layout = <<EOD
<h1>Footer</h1>
EOD
				comv.version_comment = "Initial, generated version"
				comv.version_stub_id = com.id
				comv.editor_id = 0
				raise comv.errors.full_messages.join(', ') unless comv.save

				dr = PageLayoutScheduleDateRange.new
				dr.exclusivity_id = com.id
				dr.save
				com.scheduled_version_schedule_version_with_range( comv, dr )
			end





			unless PageLayout.exists?(  { :programmatic_name => 'header-include' } )
				com = PageLayout.new(  )
				com.programmatic_name = 'header-include'
				com.name = 'Global header that will appear on every content page'
				com.save
				comv = com.make_first_version()
				comv.layout = <<EOD
<h1>Header</h1>
EOD
				comv.version_comment = "Initial, generated version"
				comv.version_stub_id = com.id
				comv.editor_id = 0
				raise comv.errors.full_messages.join(', ') unless comv.save

				dr = PageLayoutScheduleDateRange.new
				dr.exclusivity_id = com.id
				dr.save
				com.scheduled_version_schedule_version_with_range( comv, dr )
			end





		end
	end

	def scheduled_version_current_or_last_version( t = Time.now.utc )
		scheduled_version_current( t ) || self.versions.last
	end

end
