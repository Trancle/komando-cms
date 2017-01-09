class Admin::DashboardController < ApplicationController
	layout 'admin'

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	def index
	end


end
