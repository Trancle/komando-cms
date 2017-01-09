module CW
module TaskRunner
module Task
module Sample
class TaskRunnerNoOpTask < CW::TaskRunner::Application::TaskRunnerTask

	def run
		# does nothing, but will return success

		# The task method is a short-cut for the task request that's currently running
		# you can use it to manually pull out options, start dates, or set a delay. You should NEVEr change tries or try_limit
		ret = "NOOP #{task_request.id}: OK!"
		ret += ' created from: ' + options[:created_from] if options[:created_from]
		ret
	end

	def self.schedule( task_runner_request_klass_name = 'TaskRunnerRequest' )
		t = task_runner_request_klass_name.constantize.new( :task_class_name => self.name, :options => options_to_text( { :created_from => 'self.schedule' } ) )
		t.save
		t
	end

end


class TaskRunnerFailTask < CW::TaskRunner::Application::TaskRunnerTask
	def run
		raise 'fail'
	end
	def self.schedule( task_runner_request_klass_name = 'TaskRunnerRequest' )
		t = task_runner_request_klass_name.constantize.new( :task_class_name => self.name, :options => options_to_text( { :created_from => 'self.schedule' } ) )
		t.try_limit = 1
		t.save
		t
	end
end

end#Sample
end#Task
end#TaskRunner
end#CW
