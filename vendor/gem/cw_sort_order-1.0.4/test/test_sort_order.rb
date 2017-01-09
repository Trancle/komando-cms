require 'test/unit'
require 'cw_sort_order'

class PaginationOrderTest < Test::Unit::TestCase

	def test_basic_creation
		o = CW::SortOrder.asc('1').desc('2').desc('3').asc('4')
		assert_equal 4, o.size
		v = o.at(0)
		assert_equal '1', v.first
		assert_equal :asc, v.last
		v = o.at(1)
		assert_equal '2', v.first
		assert_equal :desc, v.last
		v = o.at(2)
		assert_equal '3', v.first
		assert_equal :desc, v.last
		v = o.at(3)
		assert_equal '4', v.first
		assert_equal :asc, v.last
	end

	def test_short_hand_creation
		o = CW::SortOrder.up('1').dn('2').dn('3').up('4')
		assert_equal 4, o.size
		v = o.at(0)
		assert_equal '1', v.first
		assert_equal :asc, v.last
		v = o.at(1)
		assert_equal '2', v.first
		assert_equal :desc, v.last
		v = o.at(2)
		assert_equal '3', v.first
		assert_equal :desc, v.last
		v = o.at(3)
		assert_equal '4', v.first
		assert_equal :asc, v.last
	end

	def test_operator_creation
		o = CW::SortOrder.new + '1' - '2' - '3' + '4'
		assert_equal 4, o.size
		v = o.at(0)
		assert_equal '1', v.first
		assert_equal :asc, v.last
		v = o.at(1)
		assert_equal '2', v.first
		assert_equal :desc, v.last
		v = o.at(2)
		assert_equal '3', v.first
		assert_equal :desc, v.last
		v = o.at(3)
		assert_equal '4', v.first
		assert_equal :asc, v.last
	end



	def test_basic_columns_and_directions
		o = CW::SortOrder.new + '1' - '2' - '3' + '4'
		assert_equal %w(1 2 3 4), o.columns
		assert_equal [:asc,:desc,:desc,:asc], o.directions
	end

	def test_basic_reverse_columns
		o = CW::SortOrder.new + '1' - '2' - '3' - '4'
		o = o.reverse
		assert_equal %w(1 2 3 4).reverse, o.columns
		assert_equal [:asc,:desc,:desc,:desc].reverse, o.directions
	end

	def test_basic_invert
		o = CW::SortOrder.new + '1' - '2' - '3' + '4'
		o = o.invert
		assert_equal %w(1 2 3 4), o.columns
		assert_equal [:desc,:asc,:asc,:desc], o.directions
	end

	def test_basic_select
		o = CW::SortOrder.new + '1' - '2' - '3' + '4'
		o = o.select{|col,dir| dir.eql?(:asc) }
		assert_equal %w(1 4), o.columns
	end
	def test_basic_reject
		o = CW::SortOrder.new + '1' - '2' - '3' + '4'
		o = o.reject{|col,dir| dir.eql?(:asc) }
		assert_equal %w(2 3), o.columns
	end

	def test_concat
		a = CW::SortOrder.new + '1' - '2' - '3' + '4'
		b = CW::SortOrder.new + '5' + '6' + '7' - '8'
		c = CW::SortOrder.new - '9' - '10' + '11' + '12'
		o = a.concat( b ).concat( c )
		assert_equal %w(1 2 3 4 5 6 7 8 9 10 11 12), o.columns
		assert_equal [:asc,:desc,:desc,:asc,:asc,:asc,:asc,:desc,:desc,:desc,:asc,:asc], o.directions
	end

	def test_shift
		a = CW::SortOrder.new + '1' - '2' - '3' + '4'
		assert_equal ['1',:asc], a.shift
		assert_equal ['2',:desc], a.shift
		assert_equal ['3',:desc], a.shift
		assert_equal ['4',:asc], a.shift
		assert_nil a.shift
	end

	def test_to_s
		a = CW::SortOrder.new + '1' - '2' - '3' + '4'
		assert_equal "1 asc,2 desc,3 desc,4 asc", a.to_s
	end

end
