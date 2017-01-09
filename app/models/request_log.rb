class RequestLog < ActiveRecord::Base
	include CW::RequestLog::Model

	def self.destroy_older_than( t = nil )
		t = Time.now.utc - 30.days if t.nil?

		self.destroy_all( ['created_at < ?',t] )
	end
end
