class AddGlobalHeadTagInclude < ActiveRecord::Migration

	ActionView::Helpers
  def self.up

		# creates a new page layout for the global head tag include

		default_layout = ''


		transaction do
			unless PageLayout.exists?( { :programmatic_name => 'header-head-include' } )
				pl = PageLayout.new(  )
				pl.name = 'Global Header head-tag include'
				pl.programmatic_name = 'header-head-include'
				pl.description = <<EOD
<p>This template is inserted onto every page within the &lt;head&gt; tag. This allows you to insert javascripts or styles globally.</p>
<p>Example</p>
<pre>
&lt;link rel="stylesheet" href="/some/path.css" type="text/css" media="all" /&gt;
</pre>
EOD
				pl.save
				plv = pl.make_first_version()
				plv.layout = default_layout
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

  def self.down
		PageLayout.find_by_programmatic_name( 'header-head-include' ).destroy
  end
end
