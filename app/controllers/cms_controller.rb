class CmsController < ApplicationController
	hide_action :rescue_action_in_public, :rescue_action_locally
	def rescue_action_in_public(exception)
		case exception.class.name
			when 'ActiveRecord::RecordNotFound'
				render( :file => Rails.root + '/public/404.html', :status => 404 )
			else
				super
		end
	end
	def rescue_action_locally(exception)
		case exception.class.name
			when 'ActiveRecord::RecordNotFound'
				render( :file => Rails.root + '/public/404.html', :status => 404 )
			else
				super
		end
	end
end
