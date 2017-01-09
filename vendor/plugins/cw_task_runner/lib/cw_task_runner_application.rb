# CwTaskRunner
module CW
module TaskRunner
module Application


# Subclass this task class out to create tasks
# the run method will be called. any return results from run will be included in the result_text field, good place for errors :-)
class TaskRunnerTask

	attr_reader :request_klass_name, :request_id, :options

	def initialize( request_klass_name, request_id, options )
		# can't change these
		
		@options = self.class.options_from_text( options ).freeze
		@request_klass_name = request_klass_name
		@request_id = request_id
	end

	def options
		@options
	end

	def progress
		nil
	end

	def cancelable?
		false
	end

	def task_request
		@request_klass_name.constantize.find( @request_id )
	end

	def run()
		raise NotImplementedError.new( 'Please implement the task run function' )
	end

	def self.options_from_text( t )
		return {} if t.nil? or t.empty?
		YAML::load( t )
	end

	def self.options_to_text( o )
		YAML.dump(o)
	end

end



# Rails ActiveRecord class for keeping track of tasks, just include it like any other mixin
module TaskRunnerRequest

	STATES = %w(STARTED FINISHED CANCELLED DELAY).freeze

	def self.included( base )
		base.extend(ClassMethods)
	end

	def cancel
		# contact the runner, tell it to stop
	end

	def delay_until_time( t = Time.now.utc + 1.hour )
		# contact the runner, tell it to stop SIGTERM
		begin
			Process.kill( 15, self.pid )
		rescue
		end
		self.delay_until = t
		self.result = 'DELAY'
		# up the try count, if we failed
		try_again if failed?
		self.save
	end

	def delay( howlong = 1.hour )
		delay_until Time.now.utc + howlong
	end

	def running?
		return false if self.pid.nil?
		return false if self.result.eql?'FINISHED' or self.result.eql?'CANCELLED'
		begin
			Process.kill( 0, self.pid )
		rescue
			return false
		end
		return true
	end

	def complete?
		!self.completed_at.nil?
	end

	def failed?
		!self.complete? and self.tries.eql?self.try_limit
	end

	def try_again( this_many_times = 1 )
		self.try_limit += this_many_times
	end

	def stop_trying
		self.try_limit = self.tries
	end

	def trying
		self.tries += 1
	end

	def starting( process_id )
		self.pid = process_id
		self.result = 'STARTED'
		self.started_at = Time.now.utc
		self.completed_at = nil
		self.trying
		# wipe the result text
		self.result_text = ''
		self
	end

# marks the job as having crashed
	def crashed
		self.pid = nil
		self.result = nil
		self.started_at = nil
		self.completed_at = nil
	end


	module ClassMethods
		def options_from_text( t )
			CW::TaskRunner::Application::TaskRunnerTask.options_from_text(t)
		end

		def options_to_text( o )
			CW::TaskRunner::Application::TaskRunnerTask.options_to_text(o)
		end
		def next_task_to_run( t = Time.now.utc )
			# if we're over the prescribed concurrency limit: pretend as though no request is ready
			if count( find_running_tasks_options ) < maximum_concurrent_task_count 
				find( :first, { :conditions => ["( pid IS NULL ) AND ( ( result <> 'FINISHED' AND result <> 'CANCELLED' ) OR result IS NULL ) AND ( tries < try_limit ) AND ( delay_until IS NULL OR delay_until <= ? )", t], :order => 'created_at' } )
			end
		end

		def find_running_tasks_options
			{ :conditions => ['( NOT pid IS NULL )'] }
		end

		def find_first_running_after_id( theid )
			opts = find_running_tasks_options

			opts[:conditions][0] += ' AND id > ?'
			opts[:conditions] << theid

			find( :first, opts )
		end

		def any_running?
			count( find_running_tasks_options ) > 0
		end

		# by default, you may have only 1 concurrent tasks running
		# Override this function to add more (because there aren't any  you can take away logically)
		def maximum_concurrent_task_count
			1
		end

		def update_running_tasks
			# comb all running tasks and update the database to match what truly is running (wipes any dead processes and lets them start again)
			transaction do
				jobs = find( :all, :conditions => "NOT pid IS NULL AND ( result <> 'FINISHED' OR result <> 'CANCELLED' )" )
				jobs.each do |job|
					begin
						Process.kill 0, job.pid
					rescue Errno::ESRCH => e
						# process is dead!
						job.crashed
						job.save
					end
				end
			end
		end



	end#ClassMethods

end#TaskRunnerRequest



# Rails ActiveRecord class for keeping track of tasks
module TaskRunnerRequestMigration

	def self.included( base )
		base.extend(ClassMethods)
	end

	module ClassMethods
		def create_task_runner_request_table( name, &block )
			create_table name do |t|
				t.column :created_at, :timestamp, :null => false
				t.column :task_class_name, :string, :null => false
				t.column :pid, :integer
				t.column :started_at, :timestamp
				t.column :completed_at, :timestamp
				t.column :result, :string
				t.column :tries, :integer, :default => 0, :null => false
				t.column :try_limit, :integer, :default => 5
				t.column :options, :text #free-form field assumed to be serialized hash
				t.column :delay_until, :timestamp
				t.column :result_text, :text
				yield(t) if block_given?
			end
		end

		def drop_task_runner_request_table( name, &block )
			drop_table name
			yield if block_given?
		end
	end#ClassMethods

end#TaskRunnerRequestMigration

end#Application
end#TaskRunner
end#CW
