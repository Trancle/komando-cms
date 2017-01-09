module Cms::ContentHelper
	include CW::ManagedFileResource::ViewHelper

	def vc_edit_url( vc )
		ret = {}
		if mfr_or_mfrn.kind_of?( VideoContent )
			ret[:action] = 'edit'
			ret[:id] = vc.id
		else
			raise NotImplementedError.new( "configure_url takes only VideoContent subclasses" )
		end
		ret
	end

	def path_to_info_partial( record )
		"cms/content/#{VideoContent.subclass_name( record ).underscore}/#{VideoContent.sub_subclass_name( record ).underscore}_info"
	end
	def path_to_configure_form_partial( record )
		"cms/content/#{VideoContent.subclass_name( record ).underscore}/#{VideoContent.sub_subclass_name( record ).underscore}_configure_form"
	end

end
