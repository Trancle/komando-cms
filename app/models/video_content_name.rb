class VideoContentName < ActiveRecord::Base
	def self.mfr_klass_name; 'VideoContent'; end
	include CW::ManagedFileResourceName::MfrnModel

	belongs_to :uploader, :class_name => 'User', :foreign_key => 'upload_user_id'
	has_many :video_contents, :foreign_key => 'pretty_name_id'
	has_many :link_ad_spot_video_with_video_content_names, :dependent => :destroy
	has_many :ad_spot_videos, :through => :link_ad_spot_video_with_video_content_names
	has_many :episode_parts, :dependent => :destroy
	has_many :link_home_page_lineup_with_video_content_names, :dependent => :destroy
	has_many :home_page_lineups, :through => 'link_home_page_lineup_with_video_content_names'

	validates_presence_of :uploader_user_id
	validates_length_of :pretty_name, :in => 1..2000

	def safe_to_delete?( t = Time.now.utc )
		# safe to delete if there are no safe_to_delete video_contents
		# create an array containing any NOT safe to delete, if empty: all safe to delete
		!self.video_contents.detect{|v| !v.safe_to_delete?( t )}
	end

	def safe_to_delete_assuming_videos_safe_to_delete?( t = Time.now.utc ) 
# AD SCHEDULES
		# if empty, no running ads
		unless self.ad_spot_videos.detect{|a| a.will_run_in_future?( t - Setting['vms-protected-video-deletion-grace-period'].value_typed.days ) }
			# ads not running now nor within the grace period, nor will they run in the future
			# run that query again, but make sure the file has not been running for the grace period
		else
			# have running ads, never delete
			return false
		end


		# Episodes and shows
		unless self.episode_parts.detect{|p| p.will_be_available_in_future?( t - Setting['vms-protected-video-deletion-grace-period'].value_typed.days ) }
		else
			return false
		end


# Links to home page
# FIXME
=begin
		unless self.link_home_page_lineup_with_video_content_names.detect{|l| l.will_be_available_in_future?( t - Setting['vms-protected-video-deletion-grace-period'].value_typed.days ) }
			
		else
			return false
		end
=end

# all tests pass: OK to sweep
		return true
	end

	# does a database query to locate VCN's that are safe to delete, this will be beefy
# TODO right now, this function is not a database query, but simply a chained method. This will do a LOT of database queries and return ALL items safe to delete. Do not use opts[:limit|:offset] to chunk. It may not always return the right count because this only limits what is found BEFORE the NOT safe to delete entries are tossed out 
	def self.find_all_safe_to_delete( t = Time.now.utc, opts = {} )
		find(:all, opts ).select{|vcn| vcn.safe_to_delete?(t)}
	end

	def self.destroy_all_safe_to_delete( t = Time.now.utc )
		transaction do
			find_all_safe_to_delete(t).each {|x| x.destroy}
		end
	end


	def length_in_seconds
		self.video_contents.inject(0.0){|p,x| p + x.length_in_seconds }
	end

	def colonized_length
		VideoContent.colonized_length_to_s( self.length_in_seconds )
	end




end
