namespace :app do
  desc "Runs a single instance of Task Runner"
  task :task_runner_one_shot => :environment do

    require File.dirname(__FILE__) + '/../../vendor/plugins/cw_task_runner/lib/cw_task_runner_task_process.rb'
    TaskProcess.new.one_shot

  end#task :pre_load_user_input_blacklist_dirty_words
end#namespace :app
