class AddCompleteFlagToVideoContents < ActiveRecord::Migration
  def self.up
	add_column :video_contents, :configuration_complete, :bool, :default => false, :null => false


	# now, we need to set all existing records to being completely configured:
	# Normally, I'd use the classes, but for this procedure, a mass-SQL update is in order due to speed
	execute "UPDATE video_contents SET configuration_complete = 't'"
  end

  def self.down
	remove_column :video_contents, :configuration_complete
  end
end
