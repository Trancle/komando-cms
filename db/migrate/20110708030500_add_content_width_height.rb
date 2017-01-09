class AddContentWidthHeight < ActiveRecord::Migration
  def self.up
		VideoContentHostedLiveLimelightFlashLiveStream.transaction do
			add_column :video_contents, :width, :integer, :null => true
			add_column :video_contents, :height, :integer, :null => true

			VideoContentHostedOnDemandLimelightCoreStorageAndHttp.reset_column_information

			VideoContentHostedOnDemandLimelightCoreStorageAndHttp.find(:all).each do |v|
				v.update_attribute( :width, 1280 )
				v.update_attribute( :height, 720 )
			end

			VideoContentHostedLiveLimelightFlashLiveStream.reset_column_information

			VideoContentHostedLiveLimelightFlashLiveStream.find(:all).each do |v|
				v.update_attribute( :width, 1280 )
				v.update_attribute( :height, 720 )
			end
		end
  end

  def self.down
	  # raise ActiveRecord::IrreversibleMigration.new
		remove_column :video_contents, :width
		remove_column :video_contents, :height
  end
end
