require 'test_helper'

class ComponentizedProductVersionTest < ActiveSupport::TestCase
  fixtures :all

	UAS = {
		'5.3.4.1' => ComponentizedProductVersion.new( "5.3.4.1" ),
		'5.3.2.1' => ComponentizedProductVersion.new( "5.3.2.1" ),
		'5.0.4.1' => ComponentizedProductVersion.new( "5.0.4.1" ),
		'5.0.4' => ComponentizedProductVersion.new( "5.0.4" ),
		'5.0.2' => ComponentizedProductVersion.new( "5.0.2" ),
		'5.0' => ComponentizedProductVersion.new( "5.0" ),
		'4.0' => ComponentizedProductVersion.new( "4.0" )
	}.freeze

	test "same object equality" do
		assert UAS['5.3.4.1'].eql?(UAS['5.3.4.1'])
		assert_equal UAS['5.3.4.1'], UAS['5.3.4.1']
	end

	test "different object equality" do
		assert UAS['5.3.4.1'].eql?(ComponentizedProductVersion.new("5.3.4.1"))
		assert_equal UAS['5.3.4.1'], ComponentizedProductVersion.new("5.3.4.1")
	end


	test "5.0.2 major" do
		assert_equal 5, UAS['5.0.2'].major
		assert UAS['5.0.2'].major?( 5 )
	end
	test "5.0.2 not major lower" do
		assert !UAS['5.0.2'].major?( 4 )
	end
	test "5.0.2 not major higher" do
		assert !UAS['5.0.2'].major?( 6 )
	end

	test "5.3.4.1 minor" do
		assert_equal 3, UAS['5.3.4.1'].minor
		assert UAS['5.3.4.1'].minor?( 3 )
	end
	test "5.3.4.1 not minor lower" do
		assert !UAS['5.3.4.1'].minor?( 2 )
	end
	test "5.3.4.1	not minor higher" do
		assert !UAS['5.3.4.1'].minor?( 4 )
	end

	test "newer" do
		assert UAS['5.0.4'].newer?(UAS['5.0.2'])
	end
	test "not newer" do
		assert !UAS['5.0.2'].newer?(UAS['5.0.4'])
	end

	test "older" do
		assert UAS['5.0.2'].older?(UAS['5.0.4'])
	end
	test "not older" do
		assert !UAS['5.0.4'].older?(UAS['5.0.2'])
	end

	test "newer with fewer fields" do
		assert_equal 1, UAS['5.0.2'] <=> (UAS['5.0'])
		assert UAS['5.0.2'].newer?(UAS['5.0'])
	end
	test "not newer with fewer fields" do
		assert_equal -1, UAS['5.0'] <=> (UAS['5.0.2'])
		assert !UAS['5.0'].newer?(UAS['5.0.2'])
	end
	test "older with fewer fields" do
		assert_equal -1, UAS['5.0'] <=> (UAS['5.0.4'])
		assert UAS['5.0'].older?(UAS['5.0.4'])
	end
	test "not older with fewer fields" do
		assert_equal 1, UAS['5.0.2'] <=> (UAS['5.0'])
		assert !UAS['5.0.2'].older?(UAS['5.0'])
	end


  # Replace this with your real tests.
# test "the truth" do
#    assert true
#  end
end
