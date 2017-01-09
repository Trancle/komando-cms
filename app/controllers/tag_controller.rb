class TagController < ApplicationController
	skip_filter :require_login
	skip_filter :require_administrator_user

	def as_search
		redirect_to :controller => 'search', :action => 'find', :q => params[:terms].join('%20')
	end
end
