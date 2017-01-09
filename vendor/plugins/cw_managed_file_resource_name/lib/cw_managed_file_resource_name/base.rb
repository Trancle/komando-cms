module CW
module ManagedFileResourceName
module MfrnModel

	def self.included(base)
		base.extend(ClassMethods)
		raise NotImplementedError.new( "Implement class method mfr_klass_name in class including MfrnModel" ) unless base.respond_to?:mfr_klass_name
		base.has_one :mfr, :class_name => base.mfr_klass_name, :foreign_key => 'pretty_name_id', :dependent => :destroy
	end

	module ClassMethods
	end#ClassMethods

end#MfrnModel


module MfrModel

	def upload_mfrn( attrs = {} )
		self.upload( attrs )
		# grab the original file name, always
		self.original_name = attrs[self.class.uploaded_file_attribute_name].original_filename
	end

	def self.included(base)
		base.extend(ClassMethods)
		raise NotImplementedError.new( "Implement class method mfrn_klass_name in class including MfrModel" ) unless base.respond_to?:mfrn_klass_name
		base.belongs_to :pretty_name, :class_name => base.mfrn_klass_name, :foreign_key => 'pretty_name_id'
	end

	module ClassMethods
		def uploaded_pretty_name_attribute_name
			'pretty_name'
		end
	end#ClassMethods

end#Migration
end#managedFileResourceName
end#CW
