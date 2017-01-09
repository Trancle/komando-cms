class LinkShowToRelatedShow < ActiveRecord::Base

	belongs_to :show
	belongs_to :related_show, :foreign_key => :related_show_id, :class_name => 'Show'

	validates_numericality_of :weight
	validates_uniqueness_of :show_id, :scope => :related_show_id

	def validate
		self.errors.add( :realted_show_id, 'cannot link to itself' ) if self.show_id.eql?self.related_show_id
		begin
			Show.find self.related_show_id
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :related_show_id, 'does not exist' )
		end
	end

end
