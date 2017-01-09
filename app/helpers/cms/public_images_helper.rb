module Cms::PublicImagesHelper
	include CW::ManagedFileResource::ViewHelper

	def public_image_tag( im, options = {} )
		image_tag( im.virtual_path, { :alt => h(im.alt_text) }.merge( options ) )
	end
end
