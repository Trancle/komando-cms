# Model information
module CW
module ActsAs
module Versioned
module Stub
	def self.included( base )
		base.extend(ClassMethods)

		# Create version association
		base.has_many :versions, :class_name => base.versioned_model_klass.name, :dependent => :destroy, :foreign_key => base.versioned_model_klass.versioning_combine_column_name_and_prefix( :stub_id )
	end





	def version( version_number )
		if version_number.is_a?(Symbol)
			return self.class.versioned_model_klass.find(version_number,:conditions => ["#{self.class.versioned_model_klass.versioning_combine_column_name_and_prefix(:stub_id)} = ?", self.id], :order => 'id' )
		elsif version_number.is_a?(Numeric)
			return self.class.versioned_model_klass.find(:first,:conditions => ["#{self.class.versioned_model_klass.versioning_combine_column_name_and_prefix(:stub_id)} = ?", self.id], :order => 'id', :offset => version_number - 1 ) if version_number > 0
		else
			raise NotImplementedError.new( "method version only accepts :first, :last, and a specific version #" )
		end
	end

	def make_first_version
		v = self.class.versioned_model_klass.new
		v.send( v.class.versioning_combine_column_name_and_prefix( :stub_id ).to_s + '=', self.id )
		v
	end

	def version_count
		self.class.versioned_model_klass.count(:conditions => ["#{self.class.versioned_model_klass.versioning_combine_column_name_and_prefix(:stub_id)} = ?", self.id] )
	end


	module ClassMethods
		# Over-ride this function if you didn't simply append "Version" to the model name and need to specify the name of the table explicitly
		def versioned_model_table_name
			versioned_model_table_name_default
		end
		# Over-ride this function if you didn't simply append "Version" to the model name.
		def versioned_model_klass
			versioned_model_klass_name_default.constantize
		end
		def versioned_model_klass_name_default
			# over-rideable, but used internally for centralization
		  self.versioned_model_klass_name_name_default
		end

		def versioned_model_klass_name_name_default
			# by the time this runs, we'll be included in a class...
			self.name + 'Version'
		end

		def versioned_model_table_name_default
			# by the time this runs, we'll be included in a class...
			self.name.tableize.singularize + '_versions'
		end


		# modifying find is too complex and modifies the inherent expected behavior. While less clean, specifing a new search function that will incorporate results from 2 tables into a single stub, is preferred. This query will return SEVERAL results depending on the version match, any that match a stub will be returned inside the stub as inner versions.



	end #ClassMethods

end #Stub

# The "Inner Model" 
module VersionedModel
	def self.included( base )
		base.extend(ClassMethods)
		# set protected attributes:
		base.attr_protected base.versioning_specific_columns
		
		# ALL attributes are ALWAYS read-only!
		# only do this after migrations are complete. Check for the table existence first, if it doesn't exist, assume the migration has not yet run
		if base.table_exists?
			base.column_names.each do |attr_name|
				base.attr_readonly attr_name.to_sym
			end
		end

		base.belongs_to :stub, :class_name => base.versioned_stub_klass.name, :foreign_key => base.versioning_combine_column_name_and_prefix( :stub_id )
		# adds to the before_create chain as we do NOT want to override the function, including classes may wish to implement before_create
		base.before_create :version_before_create
	end

	def new_from
		ret = self.class.new( self.attributes )
		ret.send( self.class.versioning_combine_column_name_and_prefix( :stub_id ).to_s + '=', self.send( self.class.versioning_combine_column_name_and_prefix( :stub_id ) ) )
		ret.send( self.class.versioning_combine_column_name_and_prefix( :parent_id ).to_s + '=', self.id )
		ret.send( self.class.versioning_combine_column_name_and_prefix( :created_on ).to_s + '=', nil )
		ret.send( self.class.versioning_combine_column_name_and_prefix( :comment ).to_s + '=', nil )
		ret
	end

	def version_before_create
		self.send( self.class.versioning_combine_column_name_and_prefix( :created_on ).to_s + '=', Time.now.utc )
	end

	def version_number
		# no version #, not saved
		return nil if self.id.nil?
		return self.class.count( :conditions => ["#{self.class.versioning_combine_column_name_and_prefix( :stub_id )} = ? AND id <= ?",self.send( self.class.versioning_combine_column_name_and_prefix( :stub_id ) ), self.id] )
	end

	def set_version_specific_attribute( short_name, value )
		self.send( versioning_combine_column_name_and_prefix( short_name ).to_s + "=", value )
	end

	def version_parent
		parent = self.send( self.class.versioning_combine_column_name_and_prefix( :parent_id ) )
		if parent
			self.class.find( parent, :readonly => true )
		else
			return nil
		end
	end

	def version_children
		self.class.find( :all, :conditions => ["#{self.class.versioning_combine_column_name_and_prefix( :parent_id )} = ?",self.id], :readonly => true )
	end

	module ClassMethods
		def versioning_specific_columns
			[:stub_id,:created_on,:parent_id,:comment].collect{|x| versioning_combine_column_name_and_prefix(x) }
		end
		def default_versioning_specific_columns_prefix
			'version_'
		end
		def versioning_specific_columns_prefix
			default_versioning_specific_columns_prefix
		end
		def versioning_combine_column_name_and_prefix( name )
			(versioning_specific_columns_prefix + name.to_s).to_sym
		end
		def versioning_filter_out_versioned_attributes( attribute_array_or_hash )
			v = attribute_array_or_hash
			return nil if v.nil?
			c = content_columns.collect{|x|x.name}
			if v.is_a?Hash
				v.delete_if{|x,val| c.include?(x.to_s) }
			elsif v.is_a?Array
				v.reject{|x| c.include?(x.to_s) }
			else
				raise NotImplementedError.new( "Currently, this function only accepts nil, arrays or hashes" )
			end
		end
		def versioning_filter_versioned_attributes( attribute_array_or_hash )
			v = attribute_array_or_hash
			return nil if v.nil?
			c = content_columns.collect{|x|x.name}
			if v.is_a?Hash
				v.delete_if{|x,val| !c.include?(x.to_s) }
			elsif v.is_a?Array
				v.select{|x| c.include?(x.to_s) }
			else
				raise NotImplementedError.new( "Currently, this function only accepts nil, arrays or hashes" )
			end
		end
		def versioned_content_columns
			content_columns.reject{|x| versioning_specific_columns.include?(x.name.to_sym) }
		end

		def versioned_stub_klass
			versioned_stub_klass_name_default.constantize
		end

		def versioned_stub_klass_name_default
			self.name.sub("Version","")
		end
	end #ClassMethods
	
end #InnerModel

end #Versioned
end #ActsAs
end #CW
