module CW
module ManagedFileResource
	module ViewHelper
		def mfr_image_tag( model_id_hash, options = {}, file_options = { :alias => nil, :file_ext => :auto, :controller_name => nil } )
			tag( 'img', { :src => url_for_managed_file_resource( model_id_hash, file_options ) }.merge( options ) )
		end

		def link_to_mfr( text, model_id_hash, options = {}, file_options = { :alias => nil, :file_ext => :auto, :controller_name => nil } )
			link_to( text, url_for_managed_file_resource( model_id_hash, file_options ), options )
		end

		def link_to_mfr_download( text, model_id_hash, options = {}, file_options = { :alias => nil, :file_ext => :auto, :controller_name => nil } )
			link_to( text, url_for_managed_file_resource( model_id_hash, file_options.merge( :for_download => true ) ), options )
		end

		def mfr_guess_file_render_controller( model, fallback = nil )
			c = nil
			if self.respond_to?(:controller)
				# we're a view
				c = self.controller.class.default_managed_file_resource_controller if self.controller.class.respond_to?(:default_managed_file_resource_controller)
			else
				# we're a controller
				c = self.class.default_managed_file_resource_controller if self.class.respond_to?(:default_managed_file_resource_controller)
			end
			if c.nil?
				if model.kind_of?(CW::ManagedFileResource::ModelFile)
					return model.class.name.tableize # still doesn't fit? GUESS
				else
					return fallback
				end
			else
				return c
			end
		end

		def url_for_managed_file_resource( model, file_options = { :controller_name => nil, :alias => nil, :file_ext => :auto, :for_download => false }, options = {} )
			raise ArgumentError.new( 'You must specify which managed file resource to get. Model cannot be Nil' ) if model.nil?
			c = file_options[:controller_name]
			if c.nil?
				c = mfr_guess_file_render_controller( model, 'get_file' )
				raise ArgumentError.new( 'Could not determine the managed file resource render controller. Please specify it with :controller_name in the file_options field' ) if c.nil?
			end
			hsh = options.merge({:controller => c})
			hsh.merge!( :alias => file_options[:alias] ) if file_options[:alias]
			hsh.merge!( :for_download => 't' ) if file_options[:for_download]
			file_ext = file_options[:file_ext]
			if file_ext
				if file_ext.is_a?(String)
					hsh.merge!( :file_ext => file_ext )
				else
					if model.is_a?(CW::ManagedFileResource::ModelFile)
						hsh.merge!( :file_ext => model.file_extension )
					else
						hsh.merge!( :auto_file_ext => 'true' )
					end
				end
			end
			if model.is_a?(CW::ManagedFileResource::ModelFile)
				return url_for( hsh.merge({:action => 'by_id', :id => model.id}) )
			elsif model.is_a?(Fixnum)
				return url_for( hsh.merge({:action => 'by_id', :id => model}) )
			else
				return url_for( hsh.merge({:action => 'by_hash', :id => model}) )
			end
		end
		def mfr_upload_tag( upload_klass_name_or_field_name, object_name = nil, options = {} )
			n = nil
			if upload_klass_name_or_field_name.is_a?(String)
				n = upload_klass_name_or_field_name
			else
				n = (object_name || 'file') + '[' + upload_klass_name_or_field_name.uploaded_file_attribute_name.to_s + ']'
			end
			file_field_tag( n, options.merge( :name => n ) )
		end		
	end#ViewHelper
end#ManagedFileResource
end#CW
