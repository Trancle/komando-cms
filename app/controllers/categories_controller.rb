class CategoriesController < ApplicationController
	skip_filter :require_login
	skip_filter :require_administrator_user
end
