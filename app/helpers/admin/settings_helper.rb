module Admin::SettingsHelper
	def admin_settings_breadcrumbs( m, mp, *args )
		o = [{ :text => 'Site settings', :controller => '/admin/settings', :page => ((mp.nil? or m.nil?) ? (nil) : (mp.page_number_of_item(m))) }]
		o << { :text => m.name, :controller => '/admin/settings', :action => 'info', :id => m.id } if m and not m.new_record?
		nav_breadcrumbs( *(o.concat(args)) )
	end
end
