class CDNLimelightCoreStorageRemoveVideoContentFileTask < CW::TaskRunner::Application::TaskRunnerTask

	def run
		begin
			provider = VideoContentHostingProviderOnDemandLimelightCoreStorageAndHttp.find( options[:provider_id] )
			if provider.delete_from_provider( options )
				'SUCCESS'
			else
				# FAILED
				# We couldn't delete... odds are, we can't. This isn't an exception, this is an error
				'FAILED: Unable to delete "' + options[:file_hash] + options[:file_extension] + '"'
			end
		rescue StandardError => s
			r = task_request
			# we failed, try again in 1 hour
			r.delay( 1.hour )
			r.pid = nil
			r.result_text = 'FAILED: ' + s.message + "\n" + s.backtrace.first
			r.save
			# will report the proper failure
			raise s
		end
	end

	def self.make_task( video_content )
		r = TaskRunnerRequest.new( :task_class_name => self.name, :options => self.options_to_text( { :file_md5_hash => video_content.file_hash, :file_extension => video_content.file_extension, :provider_id => video_content.video_content_hosting_provider_id } ) )
		r.save
		r
	end

end
