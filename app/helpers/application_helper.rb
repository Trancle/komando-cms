# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	# creates a standard across the site
	def pagination_buttons( pagination )

		the_view = self
    s = ''
    s += form_tag( {}, {:method => 'get', :class => 'pagination-buttons'} )
    s << CW::Pagination::View.preserve_parameter_hidden_field_tags( pagination, the_view )
    s += '<div class="pager-buttons btn-group" data-items-per-page="' + pagination.items_per_page.to_s + '">'
		if pagination.first?
			s += '<button disabled="disabled" class="disabled btn first"><i class="fa fa-double-angle-left"></i> First</button>'
			s += '<button disabled="disabled" class="disabled btn previous"><i class="fa fa-angle-left"></i></button>'
		else
			s += '<button class="btn first" name="page" value="1"><i class="fa fa-double-angle-left"></i> First</button>'
			s += '<button class="btn previous" name="page" value="' + (pagination.current_page_number - 1).to_s + '"><i class="fa fa-angle-left"></i></button>'
		end
		CW::Pagination::View.page_swath( pagination, 4 ) do |page_number,is_current|
      unless is_current
        s << '<button class="btn page-number" name="page" value="' + page_number.to_s + '">' + page_number.to_s + '</button>'
      else
        s << '<button disabled="disabled" class="btn page-number disabled current" name="page" value="' + page_number.to_s + '">' + page_number.to_s + '</button>'
      end
    end
		if pagination.last?
      s += '<button disabled="disabled" class="disabled btn next"><i class="fa fa-angle-right"></i></button>'
      s += '<button disabled="disabled" class="disabled btn last">Last <i class="fa fa-double-angle-right"></i></button>'
		else
      s += '<button class="btn next" name="page" value="' + (pagination.current_page_number + 1).to_s + '"><i class="fa fa-angle-right"></i></button>'
      s += '<button class="btn last" name="page" value="' + (pagination.count_pages).to_s + '">Last <i class="fa fa-double-angle-right"></i></button>'
		end
    s += '</div></form>'

    s += form_tag( {}, {:method => 'get', :class => 'pagination-jump'} )
    s << '<div class="pager-jump">Page <input alt="Enter page to which you wish to jump" name="page" type="text" value="' + pagination.current_page_number.to_s + '" class="jumper"> of <span class="number-of-pages">' + pagination.count_pages.to_s + '</span> <button class="btn">Go</button></div>'
    s << '</form>'
		s
	end

	def login_page_url
		link_to( 'login', :controller => 'auth', :r => @controller.request.request_uri )
	end



	def mu_ex_date_range_form_tag( object_name )
		s = '<fieldset><legend>Start</legend>'
		s += "<p>#{ label_tag( object_name + '[start_at_is_nil]', 'Infinite?' ) }#{ check_box_tag( object_name + '[start_at_is_nil]', '1', instance_variable_get('@'+object_name).start_at.nil?, :class => 'checkbox' ) }</p>"
		s += "<p>#{ datetime_select( object_name, 'start_at' ) }</p>"
		s += '</fieldset>'
		s += '<fieldset><legend>End</legend>'
		s += "<p>#{ label_tag( object_name + '[end_at_is_nil]', 'Infinite?' ) }#{ check_box_tag( object_name + '[end_at_is_nil]', '1', instance_variable_get('@'+object_name).end_at.nil?, :class => 'checkbox' ) }</p>"
		s += "<p>#{ datetime_select( object_name, 'end_at' ) }</p>"
		s += '</fieldset>'
		s
	end
	def mu_ex_date_range_show( r )
		s = ( ( r.start_at.nil? ) ? ( 'Infinity' ) : ( r.start_at.to_s ) ) + ' - ' + ( ( r.end_at.nil? ) ? ( 'Infinity' ) : ( r.end_at.to_s ) )
		s += " (#{distance_of_time_in_words( r.start_at, r.end_at )})" if r.end_at and r.start_at
		s
	end

	def yes_or_no( v )
		( v ) ? ('yes') : ('no')
	end

	def submit( t, opts = {} )
		submit_tag( t, opts.merge( :class => 'submit' ) )
	end

	def button( t, d, opts = {} )
		button_to( t, d, opts.merge( :class => 'button' ) )
	end

	def truncate_middle( t, *args )
		options = args.extract_options!
		options[:end_length] = 10 unless options.key?:end_length
		options[:length] = 30 unless options.key?:length
		if t.length <= ( options[:length] )
			t
		else
			end_length = options[:end_length]
			options.delete(:end_length)
			options[:length] = options[:length] - end_length
			s = truncate( t, options )
			s + t[(end_length*-1)..-1]
		end
	end

	def type_selection_tag( object_name, class_name, text = nil )
		radio_button_tag( object_name, class_name, instance_variable_get( '@' + object_name ).eql?(class_name), :class => 'radio' ) + label_tag( object_name + '_' + class_name.downcase, text || class_name.underscore.humanize )
	end

	def type_selection_list_tag( object_name, class_names, name_overrides = {}, options = {} )
		s = tag( 'dl', options, true )
		ss = nil
		s += class_names.collect do |class_name|
			ss = '<dt>' +  type_selection_tag( object_name, class_name, name_overrides[class_name] ) + '</dt>'
			ss += '<dd>' + class_name.constantize.friendly_type_description + '</dd>'
		end.join
		s += '</dl>'
		s
	end


	def google_analytics_insertion_code( code )
		# Version: 2010/01/01
		if code.nil? or code.empty?
			''
		else
<<EOD
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', '#{code}', 'auto');
  ga('require', 'displayfeatures');
  ga('send', 'pageview');

</script>
EOD
		end
	end

	def spinner_named( name )
		content_tag( :div, image_tag( '/images/ajax-loader.gif', :alt => 'spinner' ), :style => 'display:none;width:24px;height:24px', :id => name )
	end

	def if_has_javascript( opts = {}, tag_type = :div, &block )
		# we need to keep track of the # of times we've been called so we can create unique id's in the div tags. This lets us keep the code valid XHTML and show the javascript-enabled code
		begin
			@@if_has_javascript_id += 1
		rescue NameError
			@@if_has_javascript_id = 0
		end
		theid = "if_has_javascript_uid_#{@@if_has_javascript_id}"
		concat content_tag_string( tag_type, ( ( capture(&block) || '' ) + javascript_tag( "$('##{theid}').show();" ) ), opts.merge( :style => 'display:none;', :id => theid ) )
	end

	def html_list_first_or_last_class( list, current )
		ret = []
		ret << 'first' if list.first.eql?current
		ret << 'last' if list.last.eql?current
		return ret.join(' ')
	end

	def include_ajax_login_form
		s = ''
		s += javascript_include_tag( 'application/auth/ajaxified_login.js' )
		s += '<div class="ajaxified-login" style="display:none" id="ajaxified-login-container">'
		s += '<div id="ajaxified-login-form-container">'
		s += '<div class="close">' + link_to_function( 'X', 'application_ajaxified_login_container().hide()' ) + '</div>'
		s += form_tag( { :controller => 'auth', :action => 'login' }, { :id => 'ajaxified-login-form', :onsubmit => "application_ajaxified_login_submit( 'ajaxified-login-form' ); return false;" } )
		s += render( :partial => 'auth/form', :locals => { :user => User.new } )
		s += '<p id="ajaxified-login-submit">' + submit( 'login' ) + '</p>'
		s += spinner_named( 'ajaxified-login-spinner' )
		s += '</form>'
		s += '</div>'
		s += '</div>'
		s
	end


	def header_include_layout
    username = logged_in_username
    email = nil
    user_id = nil
    if @controller.session_user
      email = @controller.session_user.email
      user_id = @controller.session_user.id
    end
		render_opts = {
			'now' => @time,
			'is_logged_in' => @controller.is_logged_in?,
      'username' => username,
      'email' => email,
      'user_id' => user_id,
			'search_form' => SearchFormDrop.new( @controller ),
      'hostname' => @controller.request.host,
      'is_ssl' => @controller.request.ssl?,
      'page_url' => url_for(:only_path => false)
		}
		render_opts
		Liquid::Template::parse( PageLayout.first( :conditions => "programmatic_name = 'header-include'" ).scheduled_version_current( @time ).layout ).render( render_opts, SearchFormWithButtonCalled )
	end

	def footer_include_layout
    render_opts = {
        'now' => @time,
        'is_logged_in' => @controller.is_logged_in?,
        'search_form' => SearchFormDrop.new( @controller ),
        'hostname' => @controller.request.host,
        'is_ssl' => @controller.request.ssl?
    }
		Liquid::Template.parse( PageLayout.first( :conditions => "programmatic_name = 'footer-include'" ).scheduled_version_current( @time ).layout ).render( render_opts, SearchFormWithButtonCalled )
	end

	def layouts_common_body_include( &block )
return <<EOD
#{ header_include_layout }
#{ yield }
#{ footer_include_layout }
#{ google_analytics_insertion_code Setting['vms-protected-google-analytics-account-id'].value }
EOD
	end



	def contextual_help_div_id_for_field( field_id )
		field_id + '_contextual_help'
	end

	def contextual_help_for( field_id, &block )
		content = capture(&block)
		did = contextual_help_div_id_for_field( field_id )
		concat("<div id=\"#{did}\" class=\"contextual-help\" style=\"display:none;\">")
		concat(content)
		concat('<p>' + link_to_function( 'hide', "$('#{did}').hide()" ) + '</p>')
		concat('</div>')
	end

	def link_to_show_contextual_help_for( field_id, text = "What's this?" )
		did = contextual_help_div_id_for_field( field_id )
		link_to_function(text, "$('##{did}').toggle()")
	end

	def confidential_field_display_message_id( model_variable_name, attribute_name )
		"#{model_variable_name}_#{attribute_name}_confidential_message"
	end

	def confidential_field_display_data_id( model_variable_name, attribute_name )
		"#{model_variable_name}_#{attribute_name}_confidential_data"
	end

# Displays a "reveal/hide" link to expose the password. Has a timer of 1 minute default to re-hide the password after the timer expires
# The idea is to prevent people from seeing the data from the physical computer screen, not to prevent password exposure over the network: use SSL for that.
	def confidential_field_reveal_control( model_variable_name, attribute_name, reveal_text = 'Click to reveal/hide', timer = 60 )
		link_to_function( reveal_text, "$('##{confidential_field_display_data_id(model_variable_name,attribute_name)}').toggle();$('##{confidential_field_display_message_id(model_variable_name,attribute_name)}').toggle();" )
	end


	# pass in block to supply custom data formatting
	def confidential_field_data( model_variable_name, attribute_name, confidential_message = '*** Confidential ***', &block )
		ret = "<span id=\"#{confidential_field_display_message_id(model_variable_name,attribute_name)}\">#{confidential_message}</span><span id=\"#{confidential_field_display_data_id(model_variable_name,attribute_name)}\" style=\"display:none;\">" 
		unless block.nil?
			ret += block.call.to_s
		else
			ret += instance_variable_get( '@' + model_variable_name ).send( attribute_name ).to_s
		end
		ret += "</span>"
		ret
	end


	def nav_breadcrumbs( controller, *args )
		s = '<ul class="breadcrumbs"><li>'
		j = []
		args.each do |a|
			title = a.delete(:text)
			j << link_to_if( ( !current_page?(a) ) , h(title), a )
		end
		cw_bread_crumbs_chain( controller ).collect do |c|
			x = {}
			# Automatically take care of adding the ID
			if c.options.has_key?(:object_iv_name)
				raise "Instance variable: '#{c.options[:object_iv_name]}' is not defined" unless controller.instance_variable_defined?(c.options[:object_iv_name])
        item = controller.instance_variable_get(c.options[:object_iv_name])
        x[:id] = 0
				x[:id] = item.id if item.is_a?(ActiveRecord::Base)
				item = nil
			end
			# take care of automatic pagination
			if c.options.has_key?(:pagination_iv_name) and !current_page?(c.url)
				pag = controller.instance_variable_get( c.options[:pagination_iv_name] )
				item = controller.instance_variable_get( c.options[:subpage_object_iv_name] )
				x[pag.page_number_param_name] = pag.page_number_of_item( item ) if pag and item
			end
=begin
Make it a link IF:
 * crumb is not the current page AND
  * no aliases to this page OR
	* current page is not an alias to the current crumb
=end
			j << link_to_if( ( !current_page?(c.url) and !c.aliases.detect{|p| current_page?(p)} and !x[:id].eql?(0)) , h(c.title(controller).to_s), x.merge(c.url) )
		end
		s += j.join('</li><li>') + '</li></ul>'
		s
	end



	def tiny_mce( element_ids, options = {} )
		opts = {
			'mode' => 'exact',
		  'elements' => element_ids.join(','),
		 'theme' => 'advanced',
		 'plugins' => 'autolink,lists,spellchecker,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template',

# Theme options
		 'theme_advanced_buttons1' => 'bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,styleselect,formatselect,fontselect,fontsizeselect',
		 'theme_advanced_buttons2' => 'cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor',
		 'theme_advanced_buttons3' => 'tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,charmap,emotions,iespell,media,advhr,|,print,|,ltr,rtl,|,fullscreen',
		 'theme_advanced_buttons4' => 'insertlayer,moveforward,movebackward,absolute,|,styleprops,spellchecker,|,cite,abbr,acronym,del,ins,attribs,|,visualchars,nonbreaking,template,blockquote,pagebreak,|,insertfile,insertimage',
		 'theme_advanced_toolbar_location' => 'top',
		 'theme_advanced_toolbar_align' => 'left',
		 'theme_advanced_statusbar_location' => 'bottom',
		 'theme_advanced_resizing' => true,

# Skin options
		 'skin' => 'o2k7',
		 'skin_variant' => 'silver',

# Example content CSS (should be your site CSS)
#'content_css' => 'css/example.css',

		}.merge(options)
		javascript_tag( "tinyMCE.init(#{opts.to_json});" )
  end



  # See /config/initializers/static-assets-uri-base.rb
  def self.theme_static_asset_uri( file )
    if file.start_with?('/')
      STATIC_ASSETS_URI_BASE_PATH + file
    else
      STATIC_ASSETS_URI_BASE_PATH + '/' + file
    end
  end

  def theme_static_asset_uri( file )
    ApplicationHelper.theme_static_asset_uri( file )
  end



  def episode_drops_from_episodes( controller, episodes, show, show_version, time = Time.utc.now )
    return [] if episodes.empty?
    ranges = EpisodeFreeScheduleDateSet.find_ranges_with_exclusivity_ids_including( 'episode_free_schedule_dates', episodes.collect{|e|e.id}, time )
    episode_free_status = EpisodeFreeScheduleDate.all(:conditions => ranges)

    episodes.map{|e|
      EpisodeDrop.new(e,e.current_version,!episode_free_status.detect{|s|
        s.exclusivity_id.eql?(e.id)
      }.nil?,e.current_version.episode_still_image,e.video_content_names.map{|vcn|
        vcn.video_contents
      }.flatten,show,show_version,controller,time)
    }
  end


  def logged_in_username
    session[:display_name] || @controller.session_user.username
  end


end
