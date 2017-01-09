class AddLayoutDescriptions < ActiveRecord::Migration

	ActionView::Helpers
  def self.up
	page = PageLayout.find( :first, :conditions => "programmatic_name = 'watch-viewer-page'" )
	page.description = <<EOD
<p>This is the page that viewers see when they want to watch the content videos.</p>
<dl>
	<dt>form</dt>
	<dd>Liquid Drop with the following methods: <dl>
		<dt>episode</dt>
		<dd>This is the episode drop. This is the episode that the viewer is watching, presently.</dd>
		<dt>otherepisodes</dt>
		<dd>This is an array of other episodes in this show</dd>
		<dt>other_episode_pagination</dt>
		<dd>This is the pagination for the otherepisodes method.</dd>
		<dt>player</dt>
		<dd>This is the embed code for the player</dd>
		<dt>comments</dt>
		<dd>This is the embed code for the commenting system provided by MMS</dd>
		<dt>page_url</dt>
		<dd>This is the URL of the current page. This is useful for sharing or embedding functions you'd like to add into this page</dd>
	</dl></dd>
</dl>
<p>Example</p>
<pre>
&lt;h1&gt;{{ episode.title }}&lt;/h1&gt;{{ player }} &lt;h2&gt;Comments&lt;/h2&gt; {{ comments }}
</pre>
EOD
	page.save
  end

  def self.down
	# this is a description change, there's not really anything to do. it was empty before
	
  end
end
