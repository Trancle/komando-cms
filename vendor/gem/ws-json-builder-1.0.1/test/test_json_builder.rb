require 'test/unit'
require 'ws-json-builder'

class JsonBuilderTest < Test::Unit::TestCase

	def setup
		@json = Com::WojnoSystems::Builder::JSON::Base.new
	end

	def teardown
	end

	def test_simple_use
		@json.object!(:object) do |o|
			o.stuff 'Stuff!'
		end

		expected = "{'object':{'stuff':'Stuff!'}}"
		not_expected = "{'object':{'stuff':'Stuff Fake!'}}"

		assert_equal expected, @json.to_s
		assert_equal expected, @json.to_s
		assert_equal expected, @json.to_json
		assert_not_equal not_expected, @json.to_s
	end



	def test_multiple_siblings
		@json.object!(:object) do |o|
			o.stuff 'Stuff!'
			o.stuff2 'Stuff 2!'
			o.stuff3 'Stuff 3!'
			o.stuff4 'Stuff 4!'
		end

		expected = "{'object':{'stuff':'Stuff!','stuff2':'Stuff 2!','stuff3':'Stuff 3!','stuff4':'Stuff 4!'}}"

		assert_equal expected, @json.to_s
	end


	def test_multiple_nested_siblings
		@json.object!(:object) do |o|
			o.stuff 'Stuff!'
			o.stuff2 'Stuff 2!'
			o.stuff3 'Stuff 3!'
			o.object!(:stuff_more) do |j|
				j.things 'This is the first'
				j.widget 'What is a widget anyway?'
			end
			o.stuff4 'Stuff 4!'
		end

		expected = "{'object':{'stuff':'Stuff!','stuff2':'Stuff 2!','stuff3':'Stuff 3!','stuff_more':{'things':'This is the first','widget':'What is a widget anyway?'},'stuff4':'Stuff 4!'}}"

		assert_equal expected, @json.to_s
	end


	def test_numbers
		@json.object!(:stuff) do |o|
			o.weight 100
			o.age 26
			o.iq 53
		end

		assert_equal "{'stuff':{'weight':100,'age':26,'iq':53}}", @json.to_s
	end


	def test_arbitrary_value
		@json.object!(:stuff) do |o|
			o.weight 'a lot'
			o.age 26
			o.pair! 'iq', 'your_moms_weight()'
		end

		assert_equal "{'stuff':{'weight':'a lot','age':26,'iq':your_moms_weight()}}", @json.to_s
		assert_not_equal "{'stuff':{'weight':'a lot','age':26,'iq':'your_moms_weight()'}}", @json.to_s
	end

	def test_with_indent
		@json = Com::WojnoSystems::Builder::JSON::Base.new( 2 )
		
		@json.object!(:stuff) do |o|
			o.weight 'a lot'
			o.age 26
			o.pair! 'iq', 'your_moms_weight()'
		end

exp = <<EOT
{'stuff':{
  'weight':'a lot',
  'age':26,
  'iq':your_moms_weight()
  }
}
EOT

		assert_equal exp, @json.to_s + "\n"
	end

	def test_with_id_key
		@json.object!(:stuff) do |o|
			o.id! 5
		end
		assert_equal "{'stuff':{'id':5}}", @json.to_s
	end

	def test_escapes
		@json.object!(:stuff) do |o|
			o.ugly 'a lot is "a lot" and there\' nothing here C:\\Program Files\\Stuff'
		end

		assert_equal "{'stuff':{'ugly':'a lot is \"a lot\" and there' nothing here C:\\Program Files\\Stuff'}}", @json.to_s
	end

	def test_array
		@json.array!(:object) do |a|
			a << 'first'
			a << 'second'
			a << a.group! do |h|
				h.key1 'value1'
				h.key2 'value2'
			end
		end

		assert_equal "{'object':['first','second',{'key1':'value1','key2':'value2'}]}", @json.to_s



		@json = Com::WojnoSystems::Builder::JSON::Base.new(0,0,false)
		@json.array!(:values) do |a|
		[1,2,3,4].each do |i|
				e = Com::WojnoSystems::Builder::JSON::Base.new
				e.test_key 'test_value' + i.to_s
				a << e
			end
		end

		assert_equal "'values':[{'test_key':'test_value1'},{'test_key':'test_value2'},{'test_key':'test_value3'},{'test_key':'test_value4'}]", @json.to_s

	end

end # JsonBuilderTest
