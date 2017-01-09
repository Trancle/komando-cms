# CwRequestLog
module CW
module RequestLog

module ActionController
	def self.included(base)
		base.extend(ClassMethods)
	end

	def request_log_log_request( &block )
		l = self.class.request_log_klass.log( self.request ) do |l|
			yield(l) if block_given?
		end
		self.request_log= l
		true # always succeed, we never fail, even if we can't record this for some reason
	end

	def request_log=( l )
		@request_log_log = l
	end

	def request_log
		@request_log_log
	end

	module ClassMethods
	end#ClassMethods

end#ActionController

module Model
	def self.included(base)
		base.extend(ClassMethods)
	end

	module ClassMethods
		def log( request, &block )
			l = self.new
			l.accept_language = self.log_truncate_to( request.headers["Accept-Language"], 64 )
			l.ip_address = request.remote_ip
			l.uri = self.log_truncate_to( request.request_uri, 2048 )
			l.referrer = self.log_truncate_to( request.headers["Referer"], 2048 )
			l.user_agent = self.log_truncate_to( request.headers["User-Agent"], 2048 )
			l.protocol = self.log_truncate_to( request.protocol, 32 )
			l.method = self.log_truncate_to( request.request_method, 32 )
			yield(l) if block_given?
			l.save
			l # return the new log, just in case someone needs it later
		end

		def log_truncate_to( str, to )
			return nil if str.nil?
			str = str.to_s
			return nil if str.empty?
			return str.slice( 0...to )
		end
	end#ClassMethods
end#Model

module Migration
	def self.included(base)
		base.extend(ClassMethods)
	end
	module ClassMethods
		def create_request_log_table( table_name, &block )
			create_table( table_name ) do |t|
				t.column :accept_language, :string, :null => true, :limit => 64
				t.column :ip_address, :string, :null => true, :limit => 64
				t.column :uri, :string, :null => true, :limit => 2048
				t.column :referrer, :string, :null => true, :limit => 2048
				t.column :user_agent, :string, :null => true, :limit => 2048
				t.column :created_at, :timestamp, :null => false
				t.column :protocol, :string, :null => true, :limit => 32
				t.column :method, :string, :null => true, :limite => 32
				
				yield(t) if block_given?
			end
		end
	end#ClassMethods
end#Migration

end#CW
end#CW
