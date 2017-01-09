module CW
module ManagedFileResourceName
module Migration

	def self.included(base)
		base.extend(ClassMethods)
	end

	module ClassMethods
		def add_managed_file_resource_name_columns_to_mfr( table_name, &block )
			add_column table_name, :original_name, :string, :limit => 2048
			add_column table_name, :pretty_name_id, :integer
			yield(table_name) if block_given?
		end
		def create_mfrn_table( table_name, &block )
			create_table table_name do |t|
				t.column :pretty_name, :string, :limit => 2048
				yield(t) if block_given?
			end
		end
		def remove_managed_file_resource_name_columns_from_mfr( table_name, &block )
			remove_column table_name, :original_name
			remove_column table_name, :pretty_name_id
			yield(table_name) if block_given?
		end
		def drop_mfrn_table( table_name, &block )
			yield(t) if block_given?
			drop_table table_name
		end
	end#ClassMethods

end#Model
end#ManagedfileResourceName
end#CW
