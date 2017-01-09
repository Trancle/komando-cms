#!/usr/bin/ruby

require 'socket'
require 'thread'

# CwTaskRunner
class TaskRunner

	def initialize
		# Output streams are now disabled.

		# see if an old PID file exists
		if File.exists?(CONFIGURATION[:pid_path])
			f = File.open(CONFIGURATION[:pid_path], File::RDONLY)
			p = f.readline.to_i
			f.close
			# check if the Process exists, if it does, we should NOT run because we'd be running 2 schedulers
			begin
				Process.kill( 0, p )
				# process is alive, quit!
				@can_run = false
				return
			rescue
				# process is dead: we can run
			end
		end
		# Write our new PID to the PID file
		f = File.open(CONFIGURATION[:pid_path], "w+")
		f.write( Process.pid.to_s )
		f.close
		@can_run = true
	end

	def run
		return unless @can_run
		begin
			# open the log file
			begin
				File.unlink( CONFIGURATION[:socket_path] )
			rescue
			end
			serv = UNIXServer.new( CONFIGURATION[:socket_path] )
			log( :info, 'TaskRunner is ready' )
			launcher = TaskLauncher.new
			loop do
				begin
					sock = serv.accept_nonblock
				rescue Errno::EAGAIN, Errno::ECONNABORTED, Errno::EPROTO, Errno::EINTR
					IO.select( [serv] )
					retry
				end

				log( :info, 'Received request on the socket' )

			end
		rescue StandardError => e
			log( :error, e.message + "\n\n" + e.backtrace.join("\n") )
		end
	end

	def log( level, msg )
		Rails.logger.send( level, 'TaskRunnerDaemon: ' + msg )
	end

	class TaskLauncher < Thread
		def initialize
			@current_task_id_mtx = Mutex.new
			@current_task_id = nil
			super() { doproc }
		end

		def doproc
			request_id_last_checked = 0
			task_klass = CONFIGURATION[:task_runner_request_klass].constantize
			log( :info, "ready" )
			loop do
				# Threads can never crash
				begin
					# sleeps if possible
					sleeping do

						# check to see if there's a job to run
						task = task_klass.next_task_to_run
						if task
							log( :info, "New task found: #{task.id}" )
							# tell the scheduler what we're working on
							current_task_id = ctid = task.id

							cid = fork do
								# delayed start
								sleep 5
								# run the task
								ENV['TASK_ID'] = ctid.to_s
								ENV['TASK_REQUEST_KLASS'] = task_klass.name.to_s
								Kernel.exec( "ruby", "script/runner", "vendor/plugins/cw_task_runner/lib/cw_task_runner_task_process.rb" )
							end
							log( :info, "New task launched: #{task.id}" )
							Process.detach(cid)
							task.starting( cid )
							task.save
						else # no task to run
							# in leiu of doing nothing, check any running tests
							# We'll test open tests one at a time until we've hit them all, then we'll cycle back and comb them over again. We'll be looking for completed processes.
							next_running = task_klass.find_first_running_after_id( request_id_last_checked )
							if next_running
								unless next_running.running?
									# not running, it must have crashed.
									next_running.crashed
									next_running.save
								end
								request_id_last_checked = next_running.id
							else
								# start over
								request_id_last_checked = 0
							end
						end

					end
				rescue StandardError => e
					log( :error, e.message + "\n\n" + e.backtrace.join("\n") )
					# we were working on something
					begin
						if current_task_id
							task = task_klass.find( current_task_id )
							task.crashed
							current_task_id = nil
						end
					rescue
					end
					return # we return because there is a serious error
				end
			end
		end

		def log( level, msg )
			Rails.logger.send( level, "TaskRunnerDaemon::TaskLauncher: " + msg )
		end

		def current_task_id
			@current_task_id_mtx.synchronize {
				return @current_task_id
			}
		end

		def current_task_id=( i )
			@current_task_id_mtx.synchronize {
				@current_task_id = i
			}
		end

		def sleeping( &block )
			wokeupat = Time.now

			yield

			# wake up every minute to process requests
			sleepforseconds = ( wokeupat + ( CONFIGURATION[:check_for_tasks_interval] || 60 ) ) - Time.now
			sleep sleepforseconds if sleepforseconds > 0
		end
	end
end

