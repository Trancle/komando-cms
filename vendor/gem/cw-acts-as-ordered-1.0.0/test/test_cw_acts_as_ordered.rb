require 'test/unit'
require 'cw-acts-as-ordered'

require 'lib/activerecord_test_connector.rb'
gem 'actionpack', '=2.3.14'
require 'active_support'
require 'active_support/test_case'
require 'active_record/fixtures'
require 'cw_sort_order'
require 'cw_condition'

require 'ruby-debug'

class User < ActiveRecord::Base
	include CW::ActsAs::Ordered::Model
	def self.acts_as_ordered_order_attribute_name
		'rank'
	end
end
class Candy < ActiveRecord::Base
	include CW::ActsAs::Ordered::Model
	def self.acts_as_ordered_order_attribute_name
		'rank'
	end
	def self.acts_as_ordered_exclusivity_attribute_name
		'user_id'
	end
end

class Watch < ActiveRecord::Base
	include CW::ActsAs::Ordered::Model
	def self.acts_as_ordered_order_attribute_name
		'rank'
	end
	def self.acts_as_ordered_exclusivity_attribute_name
		'user_id'
	end
end

# this is the migration test ;-)
class TheMigration < ActiveRecord::Migration
	include CW::ActsAs::Ordered::Migration
	def self.up
		add_order( 'User', :rank )
		add_order_with_exclusivity( 'Candy', :rank, :user_id )
	end
end
TheMigration.up

class MigrationTestWithExclusivity < ActiveRecord::Migration
	include CW::ActsAs::Ordered::Migration
	def self.up
#debugger
		add_order_with_exclusivity( 'Watch', :rank, :user_id )
	end
	def self.down
		remove_order_with_exclusivity( 'Watch', :rank, :user_id )
	end
end
class MigrationTestWithoutExclusivity < ActiveRecord::Migration
	include CW::ActsAs::Ordered::Migration
	def self.up
#debugger
		add_order( 'Watch', :rank )
	end
	def self.down
		remove_order( 'Watch', :rank )
	end
end


class CwActsAsOrderedTest < ActiveSupport::TestCase
#fixtures :users
	def setup
		Fixtures.create_fixtures( File.dirname(__FILE__) + '/fixtures/', %w(users candies) )
	end

	def teardown
		Fixtures.reset_cache
	end


	def test_migration_on_non_empty_table
		# Watches is completely empty, lets add a few records
		0.upto(9) do |i|
			Watch.new( :name => i.to_s ).save
		end
		# Ensure we ahve 10 records
		assert_equal ['0','1','2','3','4','5','6','7','8','9'], Watch.find(:all).collect{|u| u.name }

		MigrationTestWithExclusivity.up
		assert_equal [0,1,2,3,4,5,6,7,8,9], Watch.find(:all).collect{|u| u.rank }
		assert_equal 1.upto(10).to_a, Watch.find(:all).collect{|u| u.id }
		assert 0, Watch.find(:all).select{|w| w.user_id}.uniq.first

# Tests the repair holes for more than 1 mutual exclusivity group
# Also provides a good way of jumping exclusivity groups and then quickly fixing
		# You should never do this! Testing only!
		Watch.find(:all).select{|w| (w.id % 2).eql?(1) }.each {|w| w.user_id = 1; w.save }
		assert !Watch.acts_as_ordered_is_order_consistent?
		Watch.acts_as_ordered_repair_holes
		assert Watch.acts_as_ordered_is_order_consistent?
		assert_equal [0,1,2,3,4], Watch.find_in_order_for_exclusivity(0).collect{|u| u.rank }
		assert_equal [2,4,6,8,10], Watch.find_in_order_for_exclusivity(0).collect{|u| u.id }

		assert_equal [0,1,2,3,4], Watch.find_in_order_for_exclusivity(1).collect{|u| u.rank }
		assert_equal [1,3,5,7,9], Watch.find_in_order_for_exclusivity(1).collect{|u| u.id }

		MigrationTestWithExclusivity.down
		Watch.reset_column_information
		assert_equal ['id','name'], Watch.column_names.sort
		assert_equal ['0','1','2','3','4','5','6','7','8','9'], Watch.find(:all).collect{|u| u.name }

		MigrationTestWithoutExclusivity.up
		assert_equal ['0','1','2','3','4','5','6','7','8','9'], Watch.find(:all).collect{|u| u.name }
		assert_equal [0,1,2,3,4,5,6,7,8,9], Watch.find(:all).collect{|u| u.rank }

	end

	def test_has_exclusivity
		assert !User.acts_as_ordered_has_exclusivity_id?
		assert Candy.acts_as_ordered_has_exclusivity_id?
	end


# Assume there's nothing here yet, then add elements in and see if they're ordered properly
	def test_empty_add
		# clean the database
		User.delete_all
		assert User.acts_as_ordered_is_order_consistent?
		assert_equal 0, User.count


		u = User.new( :name => 'john' )
		# not yet set
		assert_nil u.rank
		assert u.save
		assert_equal 0, u.rank

		u = User.new( :name => 'bob' )
		assert u.save
		assert_equal 1, u.rank

		u = User.new( :name => 'kurisu' )
		u.rank = 1
		assert u.save
		assert_equal 1, u.rank

		users = User.find_in_order
		assert_equal ['john','kurisu','bob'], users.collect{|us| us.name}

		User.new( :name => 'karen' ).save
		User.new( :name => 'captain-blue' ).save
		User.new( :name => 'allister' ).save
		User.new( :name => 'joe' ).save

		u = User.new( :name => 'sprocket' )
		u.rank = 3
		u.save
		assert_equal 3, u.rank
		users = User.find_in_order
		assert_equal ['john','kurisu','bob','sprocket','karen','captain-blue','allister','joe'], users.collect{|us| us.name}
		assert User.acts_as_ordered_is_order_consistent?
		
	end

#### Simple tests, no exclusivity groups

  def test_first_and_last
    assert User.first.acts_as_ordered_is_first?
    assert !User.first.acts_as_ordered_is_last?
    assert !User.last.acts_as_ordered_is_first?
    assert User.last.acts_as_ordered_is_last?

		users = User.find(:all)
		users = users[1..-2]
		users.each do |user|
			assert !user.acts_as_ordered_is_last?
			assert !user.acts_as_ordered_is_first?
		end
  end

	def test_swap
		from = User.find 6
		to = User.find 8
		from.swap_order_with to

		assert_equal [0,1,2,3,4,5,6,7,8,9], User.find_in_order.collect{|u| u.rank}
		assert_equal [0,1,2,3,4,5,8,7,6,9], User.find_in_order.collect{|u| u.id}

		from.swap_order_with to
		assert_equal [0,1,2,3,4,5,6,7,8,9], User.find_in_order.collect{|u| u.id}

		User.find(0).swap_order_with User.find(9)
		assert_equal [9,1,2,3,4,5,6,7,8,0], User.find_in_order.collect{|u| u.id}

		User.find(2).swap_order_with User.find(0)
		assert_equal [9,1,0,3,4,5,6,7,8,2], User.find_in_order.collect{|u| u.id}

		assert User.acts_as_ordered_is_order_consistent?
	end

# Destroy an item in the middle
	def test_destruction_of_middle
		assert_equal 10, User.count
		User.destroy(5)
		assert_equal 9, User.count
		users = User.find(:all)
		users.each_with_index do |u,i|
			assert_equal i, u.rank
		end
		c = [0,1,2,3,4,6,7,8,9]
		users.each_with_index do |u,i|
			assert_equal c[i], u.id
		end


		User.destroy(2)
		users = User.find(:all)
# Rank is preserved
		users.each_with_index do |u,i|
			assert_equal i, u.rank
		end
# IDs will be messed up
		c = [0,1,3,4,6,7,8,9]
		users.each_with_index do |u,i|
			assert_equal c[i], u.id
		end

		assert User.acts_as_ordered_is_order_consistent?
	end


	def test_move_to
		u = User.find 2
		u.move_order_to 5
		assert_equal 5, u.rank

		assert_equal [0,1,3,4,5,2,6,7,8,9], User.find_in_order.collect{|u| u.id}
		assert_equal [0,1,2,3,4,5,6,7,8,9], User.find_in_order.collect{|u| u.rank}

		u = User.find 4
		u.move_order_to 7
		assert_equal 7, u.rank
		assert_equal [0,1,3,5,2,6,7,4,8,9], User.find_in_order.collect{|u| u.id}

		u = User.find 8
		u.move_order_to 2
		assert_equal 2, u.rank
		assert_equal [0,1,8,3,5,2,6,7,4,9], User.find_in_order.collect{|u| u.id}

		u = User.find 4
		u.move_order_to 7
		assert_equal 7, u.rank
		assert_equal [0,1,8,3,5,2,6,4,7,9], User.find_in_order.collect{|u| u.id}

		u = User.find 9
# no changes expected
		u.move_order_to 9
		assert_equal 9, u.rank
		assert_equal [0,1,8,3,5,2,6,4,7,9], User.find_in_order.collect{|u| u.id}

		assert_raises( ArgumentError ) { u.move_order_to 10 }
		assert_raises( ArgumentError ) { u.move_order_to 15 }
		assert_raises( ArgumentError ) { u.move_order_to -5 }
		assert_raises( ArgumentError ) { u.move_order_to -1 }

		assert User.acts_as_ordered_is_order_consistent?
	end



	def test_moving_up
		user = User.find(0)
		assert_equal 0, user.rank
		user.move_order_down
		assert_equal 1, user.rank
		assert_equal [0,1,2,3,4,5,6,7,8,9], User.find_in_order.collect{|u| u.rank}
		assert_equal [1,0,2,3,4,5,6,7,8,9], User.find_in_order.collect{|u| u.id}

		user.move_order_down
		assert_equal 2, user.rank
		assert_equal [1,2,0,3,4,5,6,7,8,9], User.find_in_order.collect{|u| u.id}

		user.move_order_down 3
		assert_equal 5, user.rank
		assert_equal [1,2,3,4,5,0,6,7,8,9], User.find_in_order.collect{|u| u.id}

		assert_raises( ArgumentError ) {
			user.move_order_down 6
		}

		assert User.acts_as_ordered_is_order_consistent?
	end


	def test_moving_down
		user = User.find(8)
		assert_equal 8, user.rank
		user.move_order_up
		assert_equal 7, user.rank
		assert_equal [0,1,2,3,4,5,6,7,8,9], User.find_in_order.collect{|u| u.rank}
		assert_equal [0,1,2,3,4,5,6,8,7,9], User.find_in_order.collect{|u| u.id}

		u = User.find( 8 ) 
		user.move_order_up
		assert_equal 6, user.rank
		assert_equal [0,1,2,3,4,5,8,6,7,9], User.find_in_order.collect{|u| u.id}

		user.move_order_up 4
		assert_equal 2, user.rank
		assert_equal [0,1,8,2,3,4,5,6,7,9], User.find_in_order.collect{|u| u.id}

		assert_raises( ArgumentError ) {
			user.move_order_up 4
		}

		assert User.acts_as_ordered_is_order_consistent?
	end

	def test_fix_holes
		User.delete 0
		User.delete 4
		User.delete 8
		assert_equal [1,2,3,5,6,7,9], User.find_in_order.collect{|u| u.id}
		assert_equal [1,2,3,5,6,7,9], User.find_in_order.collect{|u| u.rank}

		User.acts_as_ordered_repair_holes
		assert_equal [1,2,3,5,6,7,9], User.find_in_order.collect{|u| u.id}
		assert_equal [0,1,2,3,4,5,6], User.find_in_order.collect{|u| u.rank}

		assert User.acts_as_ordered_is_order_consistent?
	end

	def test_complete_destruction_fwd
		u = User.first
		total = User.count
		while u
			u.destroy
			total -= 1
			assert_equal total, User.count
			assert_equal (0...(User.count)).to_a, User.find(:all).collect{|x| x.rank}
			u = User.first
		end
		assert_equal 0, User.count
	end
	def test_complete_destruction_bwd
		u = User.last
		total = User.count
		while u
			u.destroy
			total -= 1
			assert_equal total, User.count
			assert_equal (0...(User.count)).to_a, User.find(:all).collect{|x| x.rank}
			u = User.last
		end
		assert_equal 0, User.count
	end






#### Now with exclusivity groups

	def test_as_ordered_each_exclusivity_group
		groups = []
		candy = Candy.acts_as_ordered_each_exclusivity_group do |group|
			groups << group
		end

		assert_equal 0.upto(4).collect{|i| 0.upto(9).collect{|j| i*10 + j }}.to_a, groups.collect{|g| g.collect{|c| c.id} }.sort{|x,y| x.first <=> y.first}
	end

  def test_first_and_last_exgrp
    assert Candy.first.acts_as_ordered_is_first?
    assert !Candy.first.acts_as_ordered_is_last?
    assert !Candy.last.acts_as_ordered_is_first?
    assert Candy.last.acts_as_ordered_is_last?

		candy = Candy.acts_as_ordered_each_exclusivity_group do |group|
			assert !group.first.acts_as_ordered_is_last?
			assert !group.last.acts_as_ordered_is_first?
			assert group.last.acts_as_ordered_is_last?
			assert group.first.acts_as_ordered_is_first?

			group[1..-2].each do |candy|
				assert !candy.acts_as_ordered_is_last?
				assert !candy.acts_as_ordered_is_first?
			end
		end


		assert Candy.acts_as_ordered_is_order_consistent?
  end

	def test_detect_exclusivity_id
		assert !User.acts_as_ordered_has_exclusivity_id?
		assert Candy.acts_as_ordered_has_exclusivity_id?
	end


	def test_swap_exgrp
		assert_not_equal Candy.find(5).user_id, Candy.find(30).user_id

# These will assuredly be from different exclusivity groups
		assert_raises( ArgumentError ) { Candy.find(5).swap_order_with( Candy.find( 30 ) ) }
		assert_raises( ArgumentError ) { Candy.find(9).swap_order_with( Candy.find( 10 ) ) }
		assert_raises( ArgumentError ) { Candy.find(19).swap_order_with( Candy.find( 20 ) ) }
		assert_raises( ArgumentError ) { Candy.find(19).swap_order_with( Candy.find( 21 ) ) }
		assert_raises( ArgumentError ) { Candy.find(19).swap_order_with( Candy.find( 22 ) ) }

		assert_equal 0.upto(9).to_a, Candy.find_in_order_for_exclusivity( 43 ).collect{|u| u.rank}
		assert_equal 20.upto(29).to_a, Candy.find_in_order_for_exclusivity( 43 ).collect{|u| u.id}

		from = Candy.find( 22 )
		to = Candy.find( 25 )
		from.swap_order_with to
		assert_equal [20,21,25,23,24,22,26,27,28,29], Candy.find_in_order_for_exclusivity( 43 ).collect{|u| u.id}

		Candy.find(48).swap_order_with Candy.find(40)
		assert_equal [48,41,42,43,44,45,46,47,40,49], Candy.find_in_order_for_exclusivity( 10 ).collect{|u| u.id}

		assert Candy.acts_as_ordered_is_order_consistent?
	end




# Destroy an item in the middle
	def test_destruction_of_middle_exgrp
		assert_equal 50, Candy.count
		Candy.destroy(25)
		assert_equal 49, Candy.count

		group_ranks = { 1 => 0.upto(9).to_a, 2 => 0.upto(9).to_a, 43 => 0.upto(8).to_a, 24 => 0.upto(9).to_a, 10 => 0.upto(9).to_a }
		group_ids = { 1 => 0.upto(9).to_a, 2 => 10.upto(19).to_a, 43 => [20,21,22,23,24,26,27,28,29], 24 => 30.upto(39).to_a, 10 => 40.upto(49).to_a }
		Candy.acts_as_ordered_each_exclusivity_group do |group|
			group.each_with_index do |u,i|
				assert_equal group_ranks[group.first.user_id][i], u.rank
				assert_equal group_ids[group.first.user_id][i], u.id
			end
		end


		Candy.destroy(2)
# Rank is preserved
		group_ranks = { 1 => 0.upto(8).to_a, 2 => 0.upto(9).to_a, 43 => 0.upto(8).to_a, 24 => 0.upto(9).to_a, 10 => 0.upto(9).to_a }
		group_ids = { 1 => [0,1,3,4,5,6,7,8,9], 2 => 10.upto(19).to_a, 43 => [20,21,22,23,24,26,27,28,29], 24 => 30.upto(39).to_a, 10 => 40.upto(49).to_a }
		Candy.acts_as_ordered_each_exclusivity_group do |group|
			group.each_with_index do |u,i|
				assert_equal group_ranks[group.first.user_id][i], u.rank
				assert_equal group_ids[group.first.user_id][i], u.id
			end
		end

		assert Candy.acts_as_ordered_is_order_consistent?
	end

	def test_move_to_exgrp
		# 0,1,3,4,5,2,6,7,8,9
		c = Candy.find(2)
		c.move_order_to 5
		assert_equal 5, c.rank
		assert_equal 4, Candy.find(5).rank
		assert_equal 3, Candy.find(4).rank
		assert_equal 6, Candy.find(6).rank
		assert_equal 7, Candy.find(7).rank

		group_ranks = { 1 => 0.upto(9).to_a, 2 => 0.upto(9).to_a, 43 => 0.upto(9).to_a, 24 => 0.upto(9).to_a, 10 => 0.upto(9).to_a }
		group_ids = { 1 => [0,1,3,4,5,2,6,7,8,9], 2 => 10.upto(19).to_a, 43 => 20.upto(29).to_a, 24 => 30.upto(39).to_a, 10 => 40.upto(49).to_a }
		Candy.acts_as_ordered_each_exclusivity_group do |group|
			group.each_with_index do |u,i|
				assert_equal group_ranks[group.first.user_id][i], u.rank
				assert_equal group_ids[group.first.user_id][i], u.id
			end
		end

		Candy.find(20).move_order_to( 9 )
		group_ranks = { 1 => 0.upto(9).to_a, 2 => 0.upto(9).to_a, 43 => 0.upto(9).to_a, 24 => 0.upto(9).to_a, 10 => 0.upto(9).to_a }
		group_ids = { 1 => [0,1,3,4,5,2,6,7,8,9], 2 => 10.upto(19).to_a, 43 => [21,22,23,24,25,26,27,28,29,20], 24 => 30.upto(39).to_a, 10 => 40.upto(49).to_a }
		Candy.acts_as_ordered_each_exclusivity_group do |group|
			group.each_with_index do |u,i|
				assert_equal group_ranks[group.first.user_id][i], u.rank
				assert_equal group_ids[group.first.user_id][i], u.id
			end
		end


		Candy.find(39).move_order_to( 0 )
		group_ranks = { 1 => 0.upto(9).to_a, 2 => 0.upto(9).to_a, 43 => 0.upto(9).to_a, 24 => 0.upto(9).to_a, 10 => 0.upto(9).to_a }
		group_ids = { 1 => [0,1,3,4,5,2,6,7,8,9], 2 => 10.upto(19).to_a, 43 => [21,22,23,24,25,26,27,28,29,20], 24 => [39,30,31,32,33,34,35,36,37,38], 10 => 40.upto(49).to_a }
		Candy.acts_as_ordered_each_exclusivity_group do |group|
			group.each_with_index do |u,i|
				assert_equal group_ranks[group.first.user_id][i], u.rank
				assert_equal group_ids[group.first.user_id][i], u.id
			end
		end

# No changes expected
		Candy.find(9).move_order_to( 9 )
		group_ranks = { 1 => 0.upto(9).to_a, 2 => 0.upto(9).to_a, 43 => 0.upto(9).to_a, 24 => 0.upto(9).to_a, 10 => 0.upto(9).to_a }
		group_ids = { 1 => [0,1,3,4,5,2,6,7,8,9], 2 => 10.upto(19).to_a, 43 => [21,22,23,24,25,26,27,28,29,20], 24 => [39,30,31,32,33,34,35,36,37,38], 10 => 40.upto(49).to_a }
		Candy.acts_as_ordered_each_exclusivity_group do |group|
			group.each_with_index do |u,i|
				assert_equal group_ranks[group.first.user_id][i], u.rank
				assert_equal group_ids[group.first.user_id][i], u.id
			end
		end

		assert_raise( ArgumentError ) { Candy.find(9).move_order_to( 11 ) }
		assert_raise( ArgumentError ) { Candy.find(9).move_order_to( 15 ) }
		assert_raise( ArgumentError ) { Candy.find(9).move_order_to( -1 ) }

		assert Candy.acts_as_ordered_is_order_consistent?
	end

end
