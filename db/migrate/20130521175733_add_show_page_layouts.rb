class AddShowPageLayouts < ActiveRecord::Migration
  def self.up

    # creates a new page layout for the global head tag include

    default_layout = ''


    transaction do
      unless PageLayout.exists?( { :programmatic_name => 'shows-listing-page' } )
        pl = PageLayout.new(  )
        pl.name = 'Page layout for the show listing pages'
        pl.programmatic_name = 'shows-listing-page'
        pl.description = <<EOD
<p>This template is used on the /shows page to list the available shows on the site.</p>
EOD
        pl.save
        plv = pl.make_first_version()
        plv.layout = <<EOD
<h1>Shows!</h1>

{{ shows_pagination }}

<ul>
{% for show in shows %}
<li>{{show}}</li>
{% endfor %}
</ul>

{{ shows_pagination }}
EOD
        plv.version_comment = "Initial, generated version"
        plv.version_stub_id = pl.id
        plv.editor_id = 0
        raise plv.errors.full_messages.join(', ') unless plv.save

        dr = PageLayoutScheduleDateRange.new
        dr.exclusivity_id = pl.id
        dr.save
        pl.scheduled_version_schedule_version_with_range( plv, dr )
      end




      unless PageLayout.exists?( { :programmatic_name => 'show-thumbnail' } )
        pl = PageLayout.new(  )
        pl.name = 'Page layout for the show listing pages'
        pl.programmatic_name = 'show-thumbnail'
        pl.description = <<EOD
<p>This template is used to generate the thumbnail for each show to appear in a listing of shows. Intended to be used within shows-listing-page template.</p>
EOD
        pl.save
        plv = pl.make_first_version()
        plv.layout = <<EOD
<div>
<a href="{{ show.url_to_show_page }}">{{ show.splash_image_tag }}</a>
<span class="title"><a href="{{ show.url_to_show_page }}">{{ show.title }}</a></span><br/>
<span class="description">{{ show.description }}</span>
</div>
EOD
        plv.version_comment = "Initial, generated version"
        plv.version_stub_id = pl.id
        plv.editor_id = 0
        raise plv.errors.full_messages.join(', ') unless plv.save

        dr = PageLayoutScheduleDateRange.new
        dr.exclusivity_id = pl.id
        dr.save
        pl.scheduled_version_schedule_version_with_range( plv, dr )
      end





      unless PageLayout.exists?( { :programmatic_name => 'shows-header-include' } )
        pl = PageLayout.new(  )
        pl.name = 'Page layout for the show listing pages'
        pl.programmatic_name = 'shows-header-include'
        pl.description = <<EOD
<p>Inserted at the bottom of the head tag on the show listing page /shows.</p>
EOD
        pl.save
        plv = pl.make_first_version()
        plv.layout = '<!-- shows-header-include -->'
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
    PageLayout.find_by_programmatic_name( 'shows-header-include' ).destroy
    PageLayout.find_by_programmatic_name( 'show-thumbnail' ).destroy
    PageLayout.find_by_programmatic_name( 'shows-listing-page' ).destroy
  end
end
