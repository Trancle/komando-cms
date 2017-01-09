=begin
A module that, when included in ActiveRecord::Base inheriting objects, allows a text field to be used
as a free-form storage media by treating it as a YML field, with variables inside. These fields are exposed
as attributes, just as with active record attributes.

Each field is typed and converted for you on the fly.
=end
module FreeFormModelAttributeModel

	def self.included( base )
		base.extend(ClassMethods)
	end

	module ClassMethods

=begin
   Call to create an attribute. The collection is the variable that stores the YML

name is the name of the method.

Do not duplicate names, even across collections. Each name creates a function by that name. This is pretty critical.

t is the type: :string, :integer, :bool, :float.  No other types are provided at this time

default: the default value of this attribute. Leave blank for nil. When the YML is created, but doesn't contain a value, this will be returned instead.
=end

		def ffma_create_attribute( collection, name, t, default = nil )
			case t
				when :integer
					# before type cast
					define_method( name.to_s + "_before_type_cast" ) do
						if self.send( collection.to_s )[name.to_s].nil?
							return default
						else
							if self.send( collection.to_s )[name.to_s].is_a?(String) and self.send( collection.to_s )[name.to_s].empty?
								return default
							else
								return self.send( collection.to_s )[name.to_s] || default
							end
						end
					end
					# reader
					define_method( name ) do
						unless self.send(name.to_s + "_before_type_cast").nil?
							self.send(name.to_s + "_before_type_cast").to_i
						else
							default
						end
					end
				when :string
					# before type cast
					define_method( name.to_s + "_before_type_cast" ) do
						return self.send( collection.to_s )[name.to_s] || default
					end
					# reader
					define_method( name ) do
						unless self.send(name.to_s + "_before_type_cast").nil?
							self.send(name.to_s + "_before_type_cast").to_s
						else
							default
						end
					end
				when :bool
					# before type cast
					define_method( name.to_s + "_before_type_cast" ) do
						btc = self.send( collection.to_s )[name.to_s]
						if btc.nil?
							return nil
						else
							if btc.is_a?(String) and btc.empty?
								return default
							else
								return btc
							end
						end
					end
					# reader
					define_method( name ) do
						btc = self.send(name.to_s + "_before_type_cast")
						unless btc.nil?
							# only certain values trigger a true
							return ( btc.eql?(true) or btc.to_s.eql?('1') or btc.to_s.eql?('t') or btc.to_s.eql?('true') )
						else
							return default
						end
					end
				when :float
					# before type cast
					define_method( name.to_s + "_before_type_cast" ) do
						if self.send( collection.to_s )[name.to_s].nil?
							return default
						else
							if self.send( collection.to_s )[name.to_s].is_a?(String) and self.send( collection.to_s )[name.to_s].empty?
								return default
							else
								return self.send( collection.to_s )[name.to_s] || default
							end
						end
					end
					# reader
					define_method( name ) do
						unless self.send(name.to_s + "_before_type_cast").nil?
							self.send(name.to_s + "_before_type_cast").to_f
						else
							default
						end
					end
				
					# !:float	
				else
					raise ArgumentError.new( "type not recognized: :#{t}" )
			end # case t
			define_method( name.to_s + '=' ) {|v| self.send( collection.to_s )[name.to_s] = v; v }
			protected
			define_method( name.to_s + '_convert_to_type_casted_values_before_save' ) do
				# perform typecasting just before saving. This stores data in the database properly
				self.send( collection.to_s )[name.to_s] = self.send( name.to_s )
				true
			end
			public
			# conversion callback
			before_save ( name.to_s + '_convert_to_type_casted_values_before_save' ).to_sym
		end
	end
end
