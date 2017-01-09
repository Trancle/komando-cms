require 'test_helper'
require File.dirname(__FILE__) + '/../lib/cw_mu_ex_date_range.rb'


class CwMuExDateRangeTest < ActiveSupport::TestCase

	def self.before_save( a )
		# do nothing
	end

	include CW::MuExDateRange::Range

	AT = [Time.now,Time.now.tomorrow,Time.now.tomorrow.tomorrow,Time.now.tomorrow.tomorrow.tomorrow].freeze

	# test ranges
	TESTRANGES_A = { :a => [nil,nil], :b => [nil,AT[3]], :c => [AT[0],nil], :d => [AT[0],AT[3]] }.freeze
	TESTRANGES_B = { :a => [nil,nil], :b => [nil,AT[2]], :c => [AT[1],nil], :d => [AT[1],AT[2]] }.freeze

  # Replace this with your real tests.
  test "ranges_overlap" do
		assert self.class.ranges_overlap?( [nil,nil,nil,nil] )
		assert self.class.ranges_overlap?( [nil,nil,nil,AT[3]] )
		assert self.class.ranges_overlap?( [nil,nil,AT[0],nil] )
		assert self.class.ranges_overlap?( [nil,nil,AT[0],AT[3]] )
		assert self.class.ranges_overlap?( [nil,AT[3],nil,nil] )
		assert self.class.ranges_overlap?( [AT[0],nil,nil,nil] )
		assert self.class.ranges_overlap?( [AT[0],AT[3],nil,nil] )

		# second test set with -INF,INF
		assert self.class.ranges_overlap?( [nil,nil,nil,AT[2]] )
		assert self.class.ranges_overlap?( [nil,nil,AT[1],nil] )
		assert self.class.ranges_overlap?( [nil,nil,AT[1],AT[2]] )
		assert self.class.ranges_overlap?( [nil,AT[2],nil,nil] )
		assert self.class.ranges_overlap?( [AT[1],nil,nil,nil] )
		assert self.class.ranges_overlap?( [AT[1],AT[2],nil,nil] )

		# non-overlapping, completely disjoint
		assert !self.class.ranges_overlap?( AT )

		# end-point cases
		# overlapping @ end, completely disjoint
		assert !self.class.ranges_overlap?( AT[0], AT[1], AT[1], AT[2] )
# overlapping @ end, completely disjoint (reversed)
		assert !self.class.ranges_overlap?( AT[1], AT[2], AT[0], AT[1] )

# overlapping in middle
		assert self.class.ranges_overlap?( AT[0], AT[2], AT[1], AT[3] )
# overlapping in middle (reversed)
		assert self.class.ranges_overlap?( AT[1], AT[3], AT[0], AT[2] )

		# indefinite ends
		assert self.class.ranges_overlap?( nil, AT[1], nil, nil )
		assert self.class.ranges_overlap?( nil, AT[1], nil, AT[3] )
		assert self.class.ranges_overlap?( AT[0], nil, AT[2], nil )
		assert self.class.ranges_overlap?( AT[0], nil, AT[2], AT[3] )
		assert self.class.ranges_overlap?( nil, nil, AT[1], nil )
		assert self.class.ranges_overlap?( nil, nil, AT[1], AT[2] )
		assert self.class.ranges_overlap?( nil, AT[3], nil, AT[1] )
		assert self.class.ranges_overlap?( AT[2], nil, AT[0], nil )
		assert !self.class.ranges_overlap?( AT[2], nil, AT[0], AT[1] )
		assert self.class.ranges_overlap?( AT[2], nil, AT[0], AT[3] )
  end




	test "range_subtraction" do
		assert_equal [], self.class.range_subtract( nil, nil, nil, nil )
		assert_equal [AT[3],nil], self.class.range_subtract( nil, nil, nil, AT[3] )
		assert_equal [nil,AT[2]], self.class.range_subtract( nil, nil, AT[2], nil )
		assert_equal [nil,AT[0],AT[3],nil], self.class.range_subtract( nil, nil, AT[0], AT[3] )
		assert_equal [], self.class.range_subtract( nil, AT[0], nil,nil )

		# now we get to the fun part
		assert_equal [], self.class.range_subtract( nil, AT[0], nil, AT[3] )
		assert_equal [], self.class.range_subtract( nil, AT[0], nil, AT[0] )
		assert_equal [AT[0],AT[3]], self.class.range_subtract( nil, AT[3], nil, AT[0] )

		assert_equal [nil,AT[0]], self.class.range_subtract( nil, AT[0], AT[3], nil )
		assert_equal [nil,AT[0]], self.class.range_subtract( nil, AT[0], AT[0], nil )
		assert_equal [AT[0],AT[3]], self.class.range_subtract( nil, AT[3], AT[0], nil )

		assert_equal [nil,AT[0]], self.class.range_subtract( nil, AT[0], AT[1], AT[2] )
		assert_equal [nil,AT[0]], self.class.range_subtract( nil, AT[0], AT[0], AT[2] )
		assert_equal [nil,AT[1],AT[2],AT[3]], self.class.range_subtract( nil, AT[3], AT[1], AT[2] )
		assert_equal [nil,AT[1]], self.class.range_subtract( nil, AT[3], AT[1], AT[3] )
		assert_equal [nil,AT[1]], self.class.range_subtract( nil, AT[2], AT[1], AT[3] )
		assert_equal [nil,AT[2]], self.class.range_subtract( nil, AT[2], AT[2], AT[3] )
		assert_equal [nil,AT[1]], self.class.range_subtract( nil, AT[2], AT[1], AT[2] )

		assert_equal [], self.class.range_subtract( AT[0], nil, nil, nil )

		assert_equal [AT[3],nil], self.class.range_subtract( AT[0], nil, nil, AT[3] )
		assert_equal [AT[3],nil], self.class.range_subtract( AT[3], nil, nil, AT[0] )
		assert_equal [AT[2],nil], self.class.range_subtract( AT[2], nil, nil, AT[2] )



		assert_equal [AT[0],AT[1]], self.class.range_subtract( AT[0], nil, AT[1], nil )
		assert_equal [], self.class.range_subtract( AT[1], nil, AT[0], nil )
		assert_equal [], self.class.range_subtract( AT[2], nil, AT[2], nil )



		assert_equal [AT[0],AT[1],AT[3],nil], self.class.range_subtract( AT[0], nil, AT[1], AT[3] )
		assert_equal [AT[3],nil], self.class.range_subtract( AT[1], nil, AT[0], AT[3] )
		assert_equal [AT[3],nil], self.class.range_subtract( AT[3], nil, AT[1], AT[2] )
		assert_equal [AT[2],nil], self.class.range_subtract( AT[1], nil, AT[1], AT[2] )
		assert_equal [AT[2],nil], self.class.range_subtract( AT[2], nil, AT[1], AT[2] )



		assert_equal [], self.class.range_subtract( AT[2], AT[3], nil, nil )
		assert_equal [], self.class.range_subtract( AT[2], AT[2], nil, nil )



		assert_equal [], self.class.range_subtract( AT[0], AT[1], nil, AT[2] )
		assert_equal [], self.class.range_subtract( AT[0], AT[1], nil, AT[1] )
		assert_equal [AT[1],AT[2]], self.class.range_subtract( AT[0], AT[2], nil, AT[1] )
		assert_equal [AT[2],AT[3]], self.class.range_subtract( AT[2], AT[3], nil, AT[0] )
		assert_equal [AT[0],AT[3]], self.class.range_subtract( AT[0], AT[3], nil, AT[0] )



		assert_equal [AT[0],AT[1]], self.class.range_subtract( AT[0], AT[1], AT[2], nil )
		assert_equal [AT[0],AT[1]], self.class.range_subtract( AT[0], AT[1], AT[1], nil )
		assert_equal [AT[0],AT[1]], self.class.range_subtract( AT[0], AT[2], AT[1], nil )
		assert_equal [], self.class.range_subtract( AT[2], AT[3], AT[0], nil )
		assert_equal [], self.class.range_subtract( AT[0], AT[3], AT[0], nil )




		assert_equal [AT[0],AT[1]], self.class.range_subtract( AT[0], AT[1], AT[2], AT[3] )
		assert_equal [AT[2],AT[3]], self.class.range_subtract( AT[2], AT[3], AT[0], AT[1] )
		assert_equal [AT[2],AT[3]], self.class.range_subtract( AT[1], AT[3], AT[0], AT[2] )
		assert_equal [AT[0],AT[1]], self.class.range_subtract( AT[0], AT[2], AT[1], AT[3] )
		assert_equal [], self.class.range_subtract( AT[0], AT[2], AT[0], AT[2] )
		assert_equal [], self.class.range_subtract( AT[1], AT[2], AT[0], AT[3] )
		assert_equal [AT[0],AT[1],AT[2],AT[3]], self.class.range_subtract( AT[0], AT[3], AT[1], AT[2] )



	end

	test "failed_range_occlusion" do
		assert self.class.ranges_overlap?( Time.parse( "2010-02-21 17:28:00 -0700" ), Time.parse( '2010-02-21 18:50:00 -0700' ), nil, nil )
	end

end
Test::Unit::UI::Console::TestRunner.run(CwMuExDateRangeTest)
