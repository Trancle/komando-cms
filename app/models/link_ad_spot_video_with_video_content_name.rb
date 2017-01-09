class LinkAdSpotVideoWithVideoContentName < ActiveRecord::Base
	belongs_to :ad_spot_video, :class_name => 'AdSpot', :foreign_key => 'ad_spot_video_id'
	belongs_to :video_content_name

	validates_uniqueness_of :ad_spot_video_id, :scope => :video_content_name_id

	def validate
		begin
			VideoContentName.find( self.video_content_name_id ).nil?
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :video_content_name_id, 'does not exist' )
		end
		begin
			AdSpot.find( self.ad_spot_video_id ).nil?
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :ad_spot_video_id, 'does not exist' )
		end
	end

end
