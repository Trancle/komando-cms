module CW
module ManagedFileResource
	module Migration
		def self.included(base)
			base.extend(ClassMethods)
		end
		module ClassMethods
			def create_managed_file_resource_table( table_name, options = { :file_hash => { :limit => 128 }, :mime_type => { :limit => 255 } }, &block )
				create_table table_name do |t|
					x = options[:file_hash]
# allow null
					x[:null] = true
					t.column :file_hash, :string, x

#Mime Type can be null: allows client to guess it
					x = options[:mime_type]
					t.column :mime_type, :string, x
					t.column :reference_count, :integer, :null => false, :default => 0
					t.column :file_size, :integer, :null => false
					t.column :created_at, :timestamp
					yield(t) if block_given?
				end
				add_index table_name, :file_hash, :unique => true
			end
		end
	end#Migration
end#ManagedFileResource
end#CW
