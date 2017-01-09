class LinkHomePageLineupWithVideoContentName < ActiveRecord::Base
	include CW::ActsAs::Ordered::Model
	def self.acts_as_ordered_exclusivity_attribute_name; :home_page_lineup_id; end

	validates_uniqueness_of :home_page_lineup_id, :scope => :video_content_name_id
	validates_numericality_of :home_page_lineup_id, :only_integer => true
	validates_numericality_of :video_content_name_id, :only_integer => true

	def validate

		begin
			VideoContentName.find self.video_content_name_id
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :video_content_name_id, 'does not exist' )
		end

	end


	belongs_to :home_page_lineup
	belongs_to :video_content_name
end
