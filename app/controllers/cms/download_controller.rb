class Cms::DownloadController < ApplicationController
	
	include CW::ManagedFileResource::RenderController

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	def self.model_klass_name; 'VideoContent'; end

# allow anyone to have access, but thay have to be logged in as an administrator ;-) See ^
	def can_access_managed_file_resource?( mfr )
		true
	end
end
