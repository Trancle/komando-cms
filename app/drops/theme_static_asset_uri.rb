module LiquidFilter
  module ThemeStaticAssetUri

    # Input: The path after the static asset path defined in the /config/initializers/static-assets-uri-base-path
    def theme_static_asset_uri( input )
      ApplicationHelper.theme_static_asset_uri( input )
    end
  end
end
Liquid::Template.register_filter(LiquidFilter::ThemeStaticAssetUri)