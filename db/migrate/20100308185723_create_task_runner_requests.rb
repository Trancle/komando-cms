class CreateTaskRunnerRequests < ActiveRecord::Migration
	include CW::TaskRunner::Application::TaskRunnerRequestMigration
  def self.up
    create_task_runner_request_table :task_runner_requests do |t|
    end
  end

  def self.down
    drop_task_runner_request_table :task_runner_requests
  end
end
