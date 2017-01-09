# Composition class for data
# Allows a model to store "extra" information as text without having to know about it
# explicitly. Class performs the serialization for you
class FreeFormModelAttribute

	attr_reader :data
	def initialize( text = nil )
		if text.nil?
			@data = {}
		else
			@data = YAML.load(text)
		end
	end

	def to_composition
		if @data.is_a?(String)
			# Indicates that the wrong type was assiged to this variable. Save the value as a "raw" value
			v = @data
			@data = {}
			self['raw'] = v
		end
		YAML::dump( @data )
	end

	def []( k )
		@data[k]
	end

	def []=( k, v )
		@data[k] = v
	end

	def delete( k )
		@data.delete(k)
	end

	def clear
		@data.clear
	end

end

