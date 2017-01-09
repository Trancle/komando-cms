module CW
module ActsAs
module Versioned
module Migration

	def self.included(base)
		base.extend(ClassMethods)
	end

	module ClassMethods
		def create_versioned_table( inner_model_klass_name )
			raise "You must specify a class that includes Acts::As::Versioned::InnerModel" unless inner_model_klass_name.constantize.respond_to?('versioning_specific_columns')

			create_table( inner_model_klass_name.constantize.table_name ) do |t|
				t.column( inner_model_klass_name.constantize.versioning_combine_column_name_and_prefix(:stub_id), :integer, :null => false )
				t.column( inner_model_klass_name.constantize.versioning_combine_column_name_and_prefix(:created_on), :datetime, :null => false )
				t.column( inner_model_klass_name.constantize.versioning_combine_column_name_and_prefix(:parent_id), :integer, :null => true )
				t.column( inner_model_klass_name.constantize.versioning_combine_column_name_and_prefix(:comment), :text, :null => true )

			  #Create the reference class
			  yield(t)
			end
		end
	end#ClassMethods

end#Migration
end#Versioned
end#ActsAs
end#CW
