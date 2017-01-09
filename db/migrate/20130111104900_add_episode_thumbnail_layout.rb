class AddEpisodeThumbnailLayout < ActiveRecord::Migration

	ActionView::Helpers
  def self.up

		# creates a new page layout for episode Thumbnails

		default_layout = <<EOD
<div class="episode-thumbnail{% unless episode.is_free %} premium{% else %} free{% endunless %}" data-episode-id="{{episode.episode_id}}">
<span class="thumbnail"><a href="{{ episode.url_to_watch }}" class="episode-still-image">{{ episode.still_image_tag }}</a></span>
<span class="title"><a href="{{ episode.url_to_watch }}">{{episode.title}}</a></span>
<div class="description">{{episode.description}}</div>
<span class="duration">Duration: {{ episode.total_length_as_hh_mm_ss_colon_separators }}</span>
</div>
EOD


		transaction do
			unless PageLayout.exists?( { :programmatic_name => 'episode-thumbnail' } )
				pl = PageLayout.new(  )
				pl.name = 'Episode thumbnail'
				pl.programmatic_name = 'episode-thumbnail'
				pl.description = <<EOD
<p>This is how episodes are presented to users in a listing. This should be pretty small and include only the content within the &lt;li&gt;&lt;/li&gt; tags.</p>
<dl>
	<dt>form</dt>
	<dd>Liquid Drop with the following methods: <dl>
		<dt>episode</dt>
		<dd>This is the episode drop. This is the primary object to use to render this content</dd>
	</dl></dd>
</dl>
<p>Example</p>
<pre>
#{ERB::Util::h(default_layout)}
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
		PageLayout.find_by_programmatic_name( 'episode-thumbnail' ).destroy
  end
end
