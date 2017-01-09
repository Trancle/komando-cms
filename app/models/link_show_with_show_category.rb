class LinkShowWithShowCategory < ActiveRecord::Base
	def self.category_base_klass; 'ShowCategory'.constantize; end
	def self.category_categorizeable_klass; 'Show'.constantize; end
	include CW::ActsAs::Categorized::Link

	validates_uniqueness_of :categorizeable_id, :scope => :category_id

	def validate
		begin
			Show.find( self.categorizeable_id )
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :categorizeable_id, "does not exist" )
		end
		begin
			ShowCategory.find( self.category_id )
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :category_id, "does not exist" )
		end
	end
end
