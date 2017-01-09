module Admin::UserInputBansHelper

	def user_link_name( u )
		link_to( h(u.username), :controller => '/admin/users', :action => 'info', :id => u.id )
	end

end
