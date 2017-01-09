module CW
module ManagedFileResource

	module RenderController

		def self.included(base)
			base.extend(ClassMethods)
			base.hide_action :if_not_found, :if_access_denied, :can_access_managed_file_resource?, :render_model
		end

		def by_id
			mfr = nil
			begin
				mfr = self.class.model_klass_name.constantize.find(params[:id], :readonly => true )
			rescue ActiveRecord::RecordNotFound
			end
			if can_access_managed_file_resource?( mfr )
				render_model( mfr, ( !params[:for_download].nil? and params[:for_download].eql?('t') ), params[:alias], params[:file_ext], params[:auto_file_ext] )
			else
				if_access_denied and return
			end
		end

		def by_hash
			mfr = self.class.model_klass_name.constantize.find(:first, :conditions => ['file_hash = ?',params[:id]], :readonly => true )
			if can_access_managed_file_resource?( mfr )
				render_model( mfr, ( !params[:for_download].nil? and params[:for_download].eql?('t') ), params[:alias], params[:file_ext], params[:auto_file_ext] )
			else
				if_access_denied and return
			end
		end

		def if_not_found
			render( :file => RAILS_ROOT + '/public/404.html', :status => 404, :type => 'text/html; charset=utf-8' )
		end
		
		def if_access_denied
			render( :file => RAILS_ROOT + '/public/403.html', :status => 403, :type => 'text/html; charset=utf-8' )
		end

		def can_access_managed_file_resource?( mfr )
			!mfr.class.name.match( /public/i ).nil?
		end

		def render_model( mfr, force_download, alias_name, file_ext, auto_file_ext )
			if mfr
				if auto_file_ext and file_ext.nil?
					file_ext = mfr.file_extension
				end
				if self.class.x_sendfile_headers( mfr, self, force_download, alias_name, file_ext )
					render :nothing => true and return
				else
					if_not_found and return
				end
			else
				if_not_found and return
			end
		end

		module ClassMethods
			def model_klass_name
				raise NotImplementedError.new( "In #{self.name}, overwrite the class method: model_klass_name to return the string name of the class that includes CW::ManagedFileResource::FileModel" )
			end
			def x_sendfile_headers( model, controller, force_download = false, alias_name = nil, file_ext = nil )
				# process this first to be sure the file exists befor screwing up the response headers
				filepath = Pathname.new( RAILS_ROOT ).join(model.local_path).to_s
				return false unless File.exist?(filepath)
				controller.response.headers['X-Sendfile'] = filepath
				controller.response.headers['Content-Type'] = model.mime_type unless model.mime_type.nil? #Nil MIME allows for client to guess
				controller.response.headers['Content-Disposition'] = ''
				controller.response.headers['Content-Disposition'] << 'attachment; ' if force_download
				fname = alias_name || model.file_hash
				fname += '.' + file_ext if file_ext
				controller.response.headers['Content-Disposition'] << "filename=\"#{fname}\""
				fname = nil
				controller.response.headers['Content-length'] = model.file_size

				true
			end
		end
	end

end#ManagedFileResource
end#CW
