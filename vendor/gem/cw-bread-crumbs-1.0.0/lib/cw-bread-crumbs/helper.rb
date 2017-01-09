module CW
module BreadCrumbs
module ViewHelper

	def cw_bread_crumbs_title( controller, by = {} )
		by[:controller] = controller.request.symbolized_path_parameters[:controller] unless by.has_key?(:controller)
		by[:action] = controller.request.symbolized_path_parameters[:action] unless by.has_key?(:action)
		ActionController::BreadCrumbs::Crumbs[ by ].title(controller)
	end

	def cw_bread_crumbs_chain( controller, limit = nil, by = {} )
		by[:controller] = controller.request.symbolized_path_parameters[:controller] unless by.has_key?(:controller)
		by[:action] = controller.request.symbolized_path_parameters[:action] unless by.has_key?(:action)
		ActionController::BreadCrumbs::Crumbs.crumb_chain( by, limit )
	end

end # ViewHelper
end # BreadCrumbs
end # CW
