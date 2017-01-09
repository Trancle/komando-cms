class UpdateLlLiveStreamType < ActiveRecord::Migration
  def self.up
# convert all VideoContentHostedLive to VideoContentHostedOnDemandLimelightCoreStorage
		VideoContent.transaction do
			execute "UPDATE video_contents set type = 'VideoContentHostedLiveLimelightFlashLiveStream' WHERE video_contents.type = 'VideoContentHostedLive'"

			hp = nil
			# we have records, generate a generic hosting provider to facilitate converting all the records
			unless VideoContentHostedLiveLimelightFlashLiveStream.count.eql?(0)
				# Create a basic hosting provider for live streams
				hp = VideoContentHostingProviderLiveLimelightFlashLiveStream.new
				hp.name = 'LimeLight Flash LiveStream'
				hp.stream_protocol = 'rtmpt'
				hp.stream_host = 'example.wojnosystems.com'
				hp.stream_application_name = 'sample/application/name'
				hp.media_vault_enable = false
				hp.save!
			end

			VideoContentHostedLiveLimelightFlashLiveStream.find(:all).each do |v|
				s = v.type_information
				v.type_information = nil
				v.stream_name = s
				v.video_content_hosting_provider_id = hp.id
				v.width = 620
				v.height = 350
				v.save!
			end
		end
  end

  def self.down
		VideoContentHostedLiveLimelightFlashLiveStream.find(:all).each do |v|
			v.type_information = v.stream_url
			v.save
		end
		execute "UPDATE video_contents set type = 'VideoContentHostedLive' WHERE video_contents.type = 'VideoContentHostedLiveLimelightFlashLiveStream'"
  end
end
