class ShowCategory < ActiveRecord::Base
	def self.categorizeable_klass; 'Show'.constantize; end
	include CW::ActsAs::Categorized::Base
end
