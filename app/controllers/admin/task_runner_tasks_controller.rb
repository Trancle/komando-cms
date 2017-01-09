class Admin::TaskRunnerTasksController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :add_retries, :stop_trying

	def index
		list
		render :action => 'list'
	end

	def list_pagination; CW::Pagination::Model::ActiveRecord.new( self, 'TaskRunnerRequest', CW::SortOrder.desc('created_at'), {}, Setting['vms-protected-items-per-page'].value_typed ); end; protected :list_pagination
	def list
		@pagination = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('View') {|s|
			s.link 'running', {:action => 'running'}, {:title => 'View a listing of tasks that are currently being executed'}
			s.link 'failed', {:action => 'failed'}, {:title => 'View a listing of tasks that have failed'}
		}
	end

	def failed
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'TaskRunnerRequest', CW::SortOrder.desc('created_at'), {:conditions => "completed_at IS NULL AND tries = try_limit"}, Setting['vms-protected-items-per-page'].value_typed )
		@action_nav = CW::ActionNav::Controller::Base.new.section('View') {|s|
			s.link 'running', {:action => 'running'}, {:title => 'View a listing of tasks that are currently being executed'}
			s.link 'all', {:action => 'list'}, {:title => 'View a listing of all tasks, completed or not'}
		}
	end

	def running
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'TaskRunnerRequest', CW::SortOrder.desc('created_at'), {:conditions => "NOT pid IS NULL"}, Setting['vms-protected-items-per-page'].value_typed )
		@action_nav = CW::ActionNav::Controller::Base.new.section('View') {|s|
			s.link 'failed', {:action => 'failed'}, {:title => 'View a listing of tasks that have failed'}
			s.link 'all', {:action => 'list'}, {:title => 'View a listing of all tasks, completed or not'}
		}
	end

	def info
		@task_request = TaskRunnerRequest.find params[:id]
		@pagination = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.button 'stop trying', {:action => 'stop_trying', :id => @task_request.id}, {:class => 'button'} unless @task_request.complete?
			s.button 'retry', {:action => 'add_retries', :id => @task_request.id, :times => 1}, {:class => 'button'} if @task_request.failed?
		}
	end

	def add_retries
		@task_request = TaskRunnerRequest.find params[:id]
		t = params[:times] || 1
		t = t.to_i
		@task_request.try_again( ( t > 10 ) ? ( 10 ) : ( t ) )
		@task_request.save
		flash[:msg] = "Will retry task"
		redirect_to :action => 'info', :id => @task_request.id
	end

	def stop_trying
		@task_request = TaskRunnerRequest.find params[:id]
		@task_request.stop_trying
		@task_request.save
		flash[:msg] = "Task has been stopped"
		redirect_to :action => 'info', :id => @task_request.id
	end

end
