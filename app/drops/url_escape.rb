module LiquidFilter
module UrlEscape

	# URL escape: useful for drops :-)
	def url_escape( input )
		CGI::escape( input )
	end
end
end

Liquid::Template.register_filter(LiquidFilter::UrlEscape)
