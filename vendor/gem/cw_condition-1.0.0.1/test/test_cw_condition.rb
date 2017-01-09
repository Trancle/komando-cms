require 'test/unit'
require 'cw_condition'

class PaginationOrderTest < Test::Unit::TestCase
	def setup
	end
	def teardown
	end

	def test_nil_src
		assert_equal 'customized', CW::Condition.and( nil, 'customized' )
	end
	def test_nil_with
		assert_equal 'customized', CW::Condition.and( 'customized', nil )
	end

	def test_and
		assert_equal ['(customized) AND (color = ?)','pink'], CW::Condition.and( 'customized', ['color = ?','pink'] )
	end
	def test_or
		assert_equal ['(customized) OR (color = ?)','pink'], CW::Condition.or( 'customized', ['color = ?','pink'] )
	end
	def test_and_not
		assert_equal ['(customized) AND NOT (color = ?)','pink'], CW::Condition.and_not( 'customized', ['color = ?','pink'] )
	end
	def test_or_not
		assert_equal ['(customized) OR NOT (color = ?)','pink'], CW::Condition.or_not( 'customized', ['color = ?','pink'] )
	end

	def test_empty_condition
		assert_equal ['customized'], CW::Condition.and( 'customized', '' )
		assert_equal ['customized'], CW::Condition.and( '', 'customized' )
	end

	def test_array_string
		assert_equal ['(color = ?) AND (customized)','pink'], CW::Condition.and( ['color = ?','pink'], 'customized' )
	end
	def test_array_array
		assert_equal ['(color = ?) AND (customized = ?)','pink','ye'], CW::Condition.and( ['color = ?','pink'], ['customized = ?','ye'] )
	end

	def test_bad_arguments
		assert_raises( ArgumentError ) { CW::Condition.and( 3, 'customized' ) }
		assert_raises( ArgumentError ) { CW::Condition.and( 'customized', 5 ) }
		assert_raises( ArgumentError ) { CW::Condition.join( ['color = ?','pink'], 'customized', ['clause'] ) }
	end

	def test_chained_conditions
		conditions_for_puppies = CW::Condition.new 'EXISTS( SELECT * FROM users_with_puppies WHERE users_with_puppies.user_id = users.id )'
		conditions_for_of_age = CW::Condition.new 'users.age >= 21'
		params = {:name_is_like => 'Charles the Third'}

		# NB: dup lets us test using the same vars above as the condition class is modified with each call
		assert_equal ['((EXISTS( SELECT * FROM users_with_puppies WHERE users_with_puppies.user_id = users.id )) AND (users.age >= 21)) AND (lower(users.name) LIKE ?)','Charles the Third'], conditions_for_puppies.dup.and( conditions_for_of_age ).and( ['lower(users.name) LIKE ?',params[:name_is_like]] ).done

		assert_equal ['((EXISTS( SELECT * FROM users_with_puppies WHERE users_with_puppies.user_id = users.id )) AND NOT (users.age >= 21)) OR (lower(users.name) LIKE ?)','Charles the Third'], conditions_for_puppies.dup.and_not( conditions_for_of_age ).or( ['lower(users.name) LIKE ?',params[:name_is_like]] ).done

		assert_equal ['((EXISTS( SELECT * FROM users_with_puppies WHERE users_with_puppies.user_id = users.id )) OR NOT (users.age >= 21)) CUSTOM (lower(users.name) LIKE ?)','Charles the Third'], conditions_for_puppies.dup.or_not( conditions_for_of_age ).join( ['lower(users.name) LIKE ?',params[:name_is_like]], 'CUSTOM' ).done


		# NIL condition start.. OK!
		assert_equal ['(users.age >= 21) AND (lower(users.name) LIKE ?)','Charles the Third'], CW::Condition.new.or_not( conditions_for_of_age ).and( ['lower(users.name) LIKE ?',params[:name_is_like]] ).done
	end
end
