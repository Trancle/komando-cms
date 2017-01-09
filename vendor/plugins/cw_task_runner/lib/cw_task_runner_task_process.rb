class TaskProcess

	def initialize
		@task_id = ENV['TASK_ID'].to_i
		@task_request_klass = ENV['TASK_REQUEST_KLASS'] || 'TaskRunnerRequest'
	end

	def task_id_in_env?
		ENV.has_key?('TASK_ID')
	end

	def task_id
		@task_id
	end

	def task_klass
		@task_request_klass.constantize
	end

	def one_shot
		unless TaskRunnerRequest.any_running?
			task = TaskRunnerRequest.next_task_to_run
			if task
				task.starting( Process.pid ).save
				run_single_task( task )
			end

		end
	end

	def run_single_task( task )

		# we now have the task, instantiate the task class and run that here
		t = nil
		begin
			t = task.task_class_name.constantize
		rescue
			er = "Class: '" + task.task_class_name + "' does not exist"
			Rails.logger.error( er )
			task.result_text = er
			task.save
			return
		end

		# creates the custom task: populates it with a way to look itself up
		t = t.new( task_klass.name, task_id, task.options )
		if t.is_a?( CW::TaskRunner::Application::TaskRunnerTask )
			# execute the code
			result = 'OK'
			begin
				Rails.logger.info( "TaskProcess: Task named '#{task.task_class_name}' is starting" )
				result = t.run || 'OK'
				Rails.logger.info( "TaskProcess: Task named '#{task.task_class_name}' has finished" )
				# Job's done!

				# refresh active record object
				task = task_klass.find( task.id )
				task.pid = nil
				task.result = 'FINISHED'
				task.completed_at = Time.now.utc
				task.result_text = result.to_s
				task.save
			rescue StandardError => e
				Rails.logger.info( "TaskProcess: Task named '#{task.task_class_name}' encountered an error" )
				task = task_klass.find( task.id )
				task.result_text = e.message + "\n\n" + e.backtrace.join("\n")
				task.crashed
				task.save
			end
		else
			Rails.logger.error( "TaskProcess: Task named '#{task.task_class_name}' is NOT a subclass of CW::TaskRunner::Application::TaskRunnerTask" )
		end
	end

	def run
		return unless task_id_in_env?
		Rails.logger.info( 'TaskProcess has started' )
		task = task_klass.find( task_id )
		c = 0
		until( task.pid.eql?( Process.pid ) )
			# this means the parent process hasn't updated the database yet. Wait until they have
			sleep 10
			c += 1
			# try only 20 times before giving up
			return if c > 20
			task = task_klass.find( task_id )
		end
		run_single_task( task )
	end

end
TaskProcess.new.run
