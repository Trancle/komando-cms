require 'test/unit'
require 'cw_pagination'

class PaginationBaseTest < Test::Unit::TestCase


# Test Class: Numeric Range to be paginated
#
#	The only requirement is a maximum value set to the range. This will allow us to model any page we desire, without  backing store. Good way to test without having to have an active record hook or database. Assume numbers are monotonically increasing, starting from 0
	class NumericRange < CW::Pagination::Model::Base
		attr_accessor :current_page_number
		attr_reader :max_number
		def initialize( current_page_number, max_number, items_per_page )
			super items_per_page
			@current_page_number = current_page_number
			@max_number = max_number # inclusive number: maximum value any item can have
		end
		def items_on_page( page_number )
			r = []
			start = (page_number - 1)*items_per_page
			r << start if start <= max_number
			i = start + 1
			while r.size < items_per_page and i <= max_number
				r << i
				i += 1
			end
			r
		end
		def item_number( object )
			# just a number, it's value is it's number + 1 (0-based index)
			object + 1
		end
		def count_items
			max_number + 1
		end
	end

	def test_test_class_sanity_check
		t = NumericRange.new( 5, 800, 25 )
		assert_equal 5, t.current_page_number

		assert_equal 801, t.count_items
		assert_equal 25, t.items_on_page(1).size
		assert_equal (0..24).to_a, t.items_on_page(1)

		assert_equal 25, t.items_on_page(2).size
		assert_equal (25..49).to_a, t.items_on_page(2)

		assert_equal 32, t.count_full_pages
		assert_equal 33, t.count_pages

		assert_equal [800], t.items_on_page( t.count_pages )

		assert_equal 1, t.item_number( 0 )
		assert_equal 19, t.item_number( 18 )
		assert_equal 801, t.item_number( 800 )
	end

	def test_page_count
		t = NumericRange.new( 5, 800, 25 )
		assert_equal 33, t.count_pages
		assert_equal 32, t.count_full_pages

		t = NumericRange.new( 5, 799, 25 )
		assert_equal 32, t.count_pages
		assert_equal 32, t.count_full_pages

		t = NumericRange.new( 5, 802, 25 )
		assert_equal 33, t.count_pages
		assert_equal 32, t.count_full_pages
	end

	def test_page_validity_check
		t = NumericRange.new( 5, 800, 25 )
		assert t.valid_page_number?( 5 )
		assert t.valid_page_number?( 32 )
		assert t.valid_page_number?( 33 )
		assert t.valid_page_number?( 1 )

		assert !t.valid_page_number?( 0 )
		assert !t.valid_page_number?( 34 )
		assert !t.valid_page_number?( 1000 )

		t = NumericRange.new( 5, 10, 25 )
		assert t.valid_page_number?( 1 )
		assert !t.valid_page_number?( 0 )
		assert !t.valid_page_number?( 2 )

	end

	def test_first_and_last
		t = NumericRange.new( 5, 800, 25 )
		assert !t.first?
		assert !t.last?
		assert t.has_next_page?
		assert t.has_previous_page?

		t = NumericRange.new( 1, 800, 25 )
		assert t.first?
		assert !t.last?
		assert t.has_next_page?
		assert !t.has_previous_page?

		t = NumericRange.new( 33, 800, 25 )
		assert !t.first?
		assert t.last?
		assert !t.has_next_page?
		assert t.has_previous_page?

		t = NumericRange.new( 1, 10, 25 )
		assert t.first?
		assert t.last?
		assert !t.has_next_page?
		assert !t.has_previous_page?
	end

	def test_page_number_for_item_number
		t = NumericRange.new( 5, 800, 25 )
		assert_equal 1, t.page_number_for_item_number( 10 )
		assert_equal 2, t.page_number_for_item_number( 30 )
		assert_equal 32, t.page_number_for_item_number( 799 )
		assert_equal 33, t.page_number_for_item_number( 801 )

		assert_raise( CW::Pagination::ItemOutOfRange ) { t.page_number_for_item_number( 802 ) }
		assert_raise( CW::Pagination::ItemOutOfRange ) { t.page_number_for_item_number( 805 ) }
	end

	def test_page_number_of_item
		t = NumericRange.new( 5, 800, 25 )
		assert_equal 1, t.page_number_of_item( 0 )
		assert_equal 2, t.page_number_of_item( 30 )
		assert_equal 32, t.page_number_of_item( 799 )
		assert_equal 33, t.page_number_of_item( 800 )
	end

	def test_current_page_items
		# page is 5:
		# 1: 0..24
		# 2: 25..49
		# 3: 50..74
		# 4: 75..99
		#	5: 100..124
		t = NumericRange.new( 1, 800, 25 )
		assert_equal (0..24).to_a, t.items_for_current_page
		t = NumericRange.new( 5, 800, 25 )
		assert_equal (100..124).to_a, t.items_for_current_page

		t = NumericRange.new( 33, 800, 25 )
		assert_equal [800], t.items_for_current_page
	end

	def test_each_and_collect
		t = NumericRange.new( 5, 800, 25 )
		r = []
		t.each do |item|
			r << item
		end
		assert_equal r, t.items_for_current_page
		r = []
		r = t.collect do |item|
			item.to_s
		end
		assert_equal r, t.items_for_current_page.collect{|item| item.to_s}
	end


	def test_empty
		t = NumericRange.new( 1, 10, 25 )
		assert !t.empty?

		t = NumericRange.new( 1, -1, 25 )
		assert t.empty?

		t = NumericRange.new( -1, 10, 25 )
		assert !t.empty?

		t = NumericRange.new( 2, 10, 25 )
		assert !t.empty?
	end

	def test_page_numbers_closest_to_current_page
		t = NumericRange.new( 50, 800, 25 )
		assert_equal 45..55, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 1, 800, 25 )
		assert_equal 1..11, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 2, 800, 25 )
		assert_equal 1..11, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 3, 800, 25 )
		assert_equal 1..11, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 4, 800, 25 )
		assert_equal 1..11, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 5, 800, 25 )
		assert_equal 1..11, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 6, 800, 25 )
		assert_equal 1..11, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 7, 800, 25 )
		assert_equal 2..12, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 7, 800, 25 )
		assert_equal 5..10, t.page_numbers_closest_to_current_page( 5 )

		t = NumericRange.new( 33, 800, 25 )
		assert_equal 23..33, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 32, 800, 25 )
		assert_equal 23..33, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 31, 800, 25 )
		assert_equal 23..33, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 30, 800, 25 )
		assert_equal 23..33, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 29, 800, 25 )
		assert_equal 23..33, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 28, 800, 25 )
		assert_equal 23..33, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 27, 800, 25 )
		assert_equal 22..32, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 26, 800, 25 )
		assert_equal 21..31, t.page_numbers_closest_to_current_page( 10 )

		t = NumericRange.new( 26, 800, 25 )
		assert_equal 26..26, t.page_numbers_closest_to_current_page( 0 )

		t = NumericRange.new( 26, 800, 25 )
		assert_equal 26..27, t.page_numbers_closest_to_current_page( 1 )

		assert_raise( ArgumentError ) do
			t.page_numbers_closest_to_current_page( -1 )
		end
		assert_raise( ArgumentError ) do
			t.page_numbers_closest_to_current_page( -100 )
		end
	end

end
