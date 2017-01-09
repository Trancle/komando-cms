class SitemapController < ApplicationController

	skip_filter :require_login
	skip_filter :require_administrator_user

	def index
		@xml = Builder::XmlMarkup.new
		@urls = SitemapUrl.find
		response.content_type = "text/xml"
	end

end
