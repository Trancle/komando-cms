class CDNLimelightCoreStorageUploadVideoContentFileTask < CW::TaskRunner::Application::TaskRunnerTask

	def run
		begin
			provider = VideoContentHostingProviderOnDemandLimelightCoreStorageAndHttp.find( options[:provider_id] )
			if provider.upload_to_provider( options )
				'SUCCESS'
			else
				# failed to put a file
				'FAILED: Unable to upload "' + options[:file_hash] + options[:file_extension] + '"'
			end
		rescue StandardError => s
			r = task_request
			# we failed, try again in 1 hour
			r.delay( 1.hour )
			r.pid = nil
			r.result_text = 'FAILED: ' + s.message + "\n" + s.backtrace.first
			r.save
			raise "TASKRUNNER FAILED: \n" + s.to_s + "\n" + s.backtrace.join("\n")
		end
	end

	def self.make_task( video_content )
		r = TaskRunnerRequest.new( :task_class_name => self.name, :options => self.options_to_text( { :file_md5_hash => video_content.file_hash, :file_local_path => video_content.instance_local_file_path, :file_extension => video_content.file_extension, :provider_id => video_content.video_content_hosting_provider_id } ) )
		r.save
		r
	end

end
