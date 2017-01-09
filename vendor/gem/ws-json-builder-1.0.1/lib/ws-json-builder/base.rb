module Com
module WojnoSystems

module Builder


module JSON

class Base

	def initialize( indent = 0, initial = 0, enclose_with_braces = true )
		@enclose_with_braces = enclose_with_braces
		@text = ''
		@indent = indent
		@initial_level  = initial
		@is_first_in_level = [true]
	end

	def new!( enclose_with_braces = false )
		self.class.new( @indent, level, enclose_with_braces )
	end

	def <<(text)
		_comma
		_value(text)
		self
	end

	def object!(sym, value = nil, &block)
		# They're starting their own block (nesting data)
		unless value.nil?
			raise ArgumentError, "JSONMarkup cannot mix a text argument with a block"
		end
		_key(sym)
		_text('{')
		_newline
		_nested_structures(block)
		_indent
		_text('}')
		_newline
		self
	end

	def method_missing(sym, value = nil)
		_create_pair(sym,value)
		self
	end

	def array!( sym = nil, &block )
		unless sym.nil?
			_key(sym)
		else
			_comma
		end
		_text('[')
		_newline
		_nested_structures(block)
		_indent
		_text(']')
		_newline
		self
	end

	def nil?()
		false
	end

# like tag, but you're not creating a tag, but a subgroup
	def group!( &block )
		n = new!( true )
		block.call(n)
		n
	end

	def pair!( key, value )
		_key(key)
		_text(value)
		self
	end

	def to_s
		if @enclose_with_braces
			return '{' + @text + '}'
		else
			return @text
		end
	end
	alias :to_json :to_s

	def id!( value )
		pair!('id',value)
		self
	end

	private

	def _escape(text)
		# only removing the quotes
		text.gsub('\\','\\\\').gsub("'","\\'")
	end

	def _newline
		return if @indent == 0
		_text("\n")
	end

	def _indent
		return if @indent == 0 || level == 0
		_text(" " * (level * @indent))
	end

	def _nested_structures(block)
		@is_first_in_level << true
		_indent()
		block.call(self)
	ensure
		_newline
		_indent
		@is_first_in_level.pop
	end

	def level
		@is_first_in_level.size + @initial_level - 1
	end

	def _create_pair(sym,value)
		_key(sym)
		_value(value)
	end

	def _value(value)
		if value.respond_to?(:to_json)
			_text(value.to_json)
		else
			# Numbers are not quoted
			if value.is_a?(Numeric)
				_text(value)
			elsif value.is_a?(Base) # allows nesting
				_text(value)
			else # Assume it's text, or that it's serializable as text
				_text("'" + value.to_s + "'")
			end
		end
	end

	def _comma
		if @is_first_in_level.last
			@is_first_in_level[@is_first_in_level.size - 1] = false
		else
			_text(',')
			_newline()
			_indent()
		end
	end

	def _key(sym)
		_comma
		_text("\"#{_escape(sym.to_s)}\":")
	end

	def _text(text)
		@text += text.to_s
	end


end # Base

end # JSON

end # Builder

end # WojnoSystems
end #Com
