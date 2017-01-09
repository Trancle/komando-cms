class UpdateLlOnDemandType < ActiveRecord::Migration
  def self.up
# convert all VideoContentHostedOnDemand to VideoContentHostedOnDemandLimelightCoreStorage
		VideoContent.transaction do
			execute "UPDATE video_contents set type = 'VideoContentHostedOnDemandLimelightCoreStorageAndHttp' WHERE video_contents.type = 'VideoContentHostedOnDemand'"

			hp = nil
			# we have records, generate a generic hosting provider to facilitate converting all the records
			unless VideoContentHostedOnDemandLimelightCoreStorageAndHttp.count.eql?(0)
				# Create a basic hosting provider for live streams
				hp = VideoContentHostingProviderOnDemandLimelightCoreStorageAndHttp.new
				hp.name = 'LimeLight On Demand Flash and HTTP'
				hp.origin_ftp_username = 'change_me'
				hp.origin_ftp_password = 'change_me'
				hp.origin_ftp_host = 'ftp.example.com'

				hp.download_flash_host = 'flash.example.com'
				hp.download_flash_application_name = '/change_me'
				hp.download_flash_path_prefix = 'change_me'
				hp.download_http_host = 'http.example.com'
				hp.download_http_application_name = '/change_me'
				hp.download_http_path_prefix = 'change_me'


				hp.media_vault_enable = true
				hp.media_vault_secret = 'change_me_change_me'
				hp.media_vault_uri_base = 'change_me'

				hp.media_vault_security_enforce_time = true


				hp.storage_folder_max_name_length = 3
				hp.storage_folder_max_depth = -1
				hp.save!
			end


			VideoContentHostedOnDemandLimelightCoreStorageAndHttp.find(:all).each do |v|
				# These are all the defaults for WestStar's videos
				v.video_content_hosting_provider_id = hp.id
				v.audio_codec = 'mp4a.40.2'
				v.video_codec = 'avc1.42E01E'
				v.frames_per_second = 24.0
				v.width = 620
				v.height = 350
				v.save!
			end
		end
  end

  def self.down
		execute "UPDATE video_contents set type = 'VideoContentHostedOnDemand', type_information = NULL WHERE video_contents.type = 'VideoContentHostedOnDemandLimelightCoreStorageAndHttp'"

  end
end
