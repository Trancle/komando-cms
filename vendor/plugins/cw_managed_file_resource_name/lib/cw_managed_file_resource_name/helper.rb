module CW
module ManagedFileResourceName
module ViewHelper

	def image_tag_mfrn( name_model, options = {}, file_options = {} )
		unless options.has_key?(:alt)
			options[:alt] = name_model.pretty_name || name_model.original_name
		end
		alias_name = name_model.original_name
		if alias_name.nil?
			alias_name = name_model.pretty_name
			unless alias_name.nil?
				file_options[:ext] = :auto
			end
		end
		file_options[:alias] = alias_name
		file_options[:controller_name] = mfr_guess_file_render_controller( name_model.class.managed_file_resource_model_klass.name.tableize ) unless file_options[:controller_name]
		raise ArgumentError.new( 'Could not determine the managed file resource render controller. Please specify it with :controller_name in the file_options field' ) if file_options[:controller_name].nil?
		image_tag_mfr( name_model.managed_file_resource_id, options, file_options )
	end

end#ViewHelper
end#ManagedFileResourceName
end#CW
