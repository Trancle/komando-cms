require 'test/unit'
require 'cw_pagination'

require 'lib/activerecord_test_connector.rb'
gem 'actionpack', '=2.3.14'
gem 'cw_sort_order', '>=1.0.1'
require 'cw_sort_order'
require 'cw_condition'
require 'active_support'
require 'active_support/test_case'
require 'action_controller'
require 'action_controller/test_process'

class User < ActiveRecord::Base
end
class UserController < ActionController::Base

	def list
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'User', CW::SortOrder.new + 'last' + 'first' + 'middle' - 'age' - 'height', {}, 5 )
		render :nothing => true
	end

	def all
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'User', CW::SortOrder.new + 'last' + 'first' + 'middle' - 'age' - 'height', {}, 25 )
		render :nothing => true
	end

	def all_unordered
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'User', nil, {}, 25 )
		render :nothing => true
	end

	def order_by_id
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'User', CW::SortOrder.asc('id'), {}, 5 )
		render :nothing => true
	end

	def page_manually_set
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'User', CW::SortOrder.new + 'id', {}, 5 )
		params[:page] = 3
		render :nothing => true
	end


	def page_set_to_page_item_is_on
		@user = User.find(11)
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'User', CW::SortOrder.new + 'id', { :conditions => ['lower(last) like ?','%e%'] }, 5 )
		@original_query = @pagination.query
		params[:page] = @pagination.page_number_of_item( @user )
		render :nothing => true
	end


	# Encountered something similar when implementing, sorting by ID, and have a filter
	def age_equals
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'User', CW::SortOrder.desc('id'), { :conditions => ['age = ?',params[:age]] }, 5 )
		render :nothing => true
	end


	def page_param
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'User', CW::SortOrder.new + 'last' + 'first' + 'middle' - 'age' - 'height', {}, 5 )
		@pagination.page_number_param_name = 'diff_param'
		render :nothing => true
	end
# Allows users to sort the data themselves... Could be dangerous if they can specify ordering columns
	def custom_sort
		# expecing order to be like: "+col,-col,+col..."
		orderp = params[:order].split(',')
		
		order = CW::SortOrder.new
		orderp.each do |o|
			c = o[0..0]
			o = o[1..-1]
			if c.eql?'-'
				order.desc o
			else
				order.asc o
			end
		end

		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'User', order, {}, 5 )
		render :nothing => true
	end

	def ordered_filtered_results
		# expecing order to be like: "+col,-col,+col..."
		orderp = params[:order].split(',')
		
		order = CW::SortOrder.new
		orderp.each do |o|
			c = o[0..0]
			o = o[1..-1]
			if c.eql?'-'
				order.desc o
			else
				order.asc o
			end
		end

		filter = '%' + params[:filter] + '%'

		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'User', order, { :conditions => ['last like ?', filter] }, 5 )
		render :nothing => true
	end

end

ActionController::Routing::Routes.draw do |map|
	map.connect 'users/:action', :controller => 'user'
end

class PaginationActiveRecordTest < ActionController::TestCase



	tests UserController

	def setup
		Fixtures.create_fixtures( File.dirname(__FILE__) + '/fixtures', 'users' )
	end

	def teardown
	end

	def test_active_record
		assert_equal 22, User.count
		u = User.find 10
		assert_equal 'Kathrine', u.first
		assert_equal 'Pulsifer', u.middle
		assert_equal 'Maston', u.last
		assert_equal 25, u.age
		assert_equal 129, u.height
	end


	def test_simple_pagination
		get :list
		assert_response :success
		assert_not_nil assigns(:pagination)

		p = assigns(:pagination)

		assert_equal 5, p.items_per_page
		assert_equal 22, p.count_items
		assert_equal 5, p.count_pages
		assert_equal 1, p.current_page_number
	end

	def test_pagination_no_order
		get :all_unordered
		assert_response :success
		assert_not_nil assigns(:pagination)
	end

	def test_page_two
		get :list, :page => 2
		assert_response :success
		assert_not_nil assigns(:pagination)

		p = assigns(:pagination)
		assert_equal 2, p.current_page_number
	end

	def test_first_and_last_items_of_all
		get :order_by_id, :page => 2
		p = assigns(:pagination)
		assert_equal 1, p.first_item_of_all.id
		assert_equal 22, p.last_item_of_all.id
	end

	def test_page_zero
		get :list, :page => 0
		assert_response :success
		assert_not_nil assigns(:pagination)

		p = assigns(:pagination)
		assert_equal 1, p.current_page_number
	end
	def test_page_negative
		get :list, :page => -1
		assert_response :success
		assert_not_nil assigns(:pagination)

		p = assigns(:pagination)
		assert_equal 1, p.current_page_number
	end
	def test_page_over
		get :list, :page => 6
		assert_response :success
		assert_not_nil assigns(:pagination)

		p = assigns(:pagination)
		assert_equal 5, p.current_page_number
		assert_equal 5, p.count_pages
	end
	def test_page_nonsense
		get :list, :page => 'bob'
		assert_response :success
		assert_not_nil assigns(:pagination)

		p = assigns(:pagination)
		assert_equal 1, p.current_page_number
	end

	def test_page_manually_set
		get :page_manually_set

		assert_response :success
		assert_not_nil assigns(:pagination)
		assert_equal 3, assigns(:pagination).current_page_number
	end

	def test_manual_set_results
		get :page_manually_set

		assert_response :success

		assert_equal 1, assigns(:pagination).page_number_of_item( User.find( 3 ) )

		assert_equal 5, assigns(:pagination).count_pages
	end

	def test_page_set_to_page_item_is_on
		get :page_set_to_page_item_is_on

		assert_response :success

		assert_equal [3,4,5,6,7,9,11,13,14,18,19,20,21,22], User.find(:all, :conditions => ['lower(last) like ?','%e%'], :order => 'id' ).collect{|u| u.id}

		assert_equal 14, User.count(:conditions => "lower(last) like '%e%'")
		assert_equal 14, assigns(:pagination).count_items

		assert_equal 2, assigns(:pagination).page_number_of_item( User.find( 11 ) )

		assert_equal 3, assigns(:pagination).count_pages

		items = assigns(:pagination).items_for_current_page

		assert_equal 5, items.size

		assert_equal 14, assigns(:pagination).count_items

		assert_equal 3, assigns(:pagination).count_pages


		assert_equal 3, assigns(:pagination).count_pages

		assert_equal assigns(:original_query), assigns(:pagination).query
		
	end

	def test_page_ordering
		get :all
		assert_response :success
		assert_not_nil assigns(:pagination)

		p = assigns(:pagination)
		assert_equal 1, p.current_page_number
		items = p.items_for_current_page
		assert_equal 22, items.size

		ordered = User.find(:all, :order => 'last, first, middle, age DESC, height DESC' )
		assert_equal 22, ordered.size

		ordered.each_with_index do |item,index|
			assert_equal item, items[index]
		end

		# This proves that the ordering is applied
	end

	def test_page_one_content
		get :list

		p = assigns(:pagination)
		items = p.items_for_current_page
		User.find(:all, :order => 'last, first, middle, age DESC, height DESC', :limit => 5 ).each_with_index do |item,index|
			assert_equal item, items[index]
		end
	end

	def test_page_two_content
		get :list, :page => 2

		p = assigns(:pagination)
		items = p.items_for_current_page
		User.find(:all, :order => 'last, first, middle, age DESC, height DESC', :limit => 5, :offset => 5 ).each_with_index do |item,index|
			assert_equal item, items[index]
		end
	end

	def test_page_five_content
		get :list, :page => 5

		p = assigns(:pagination)
		items = p.items_for_current_page
		assert_equal 2, items.size
		User.find(:all, :order => 'last, first, middle, age DESC, height DESC', :limit => 5, :offset => 20 ).each_with_index do |item,index|
			assert_equal item, items[index]
		end
	end

	def test_page_param_change
		get :page_param, :diff_param => 4

		assert_equal "4", @request.params['diff_param']
		assert_equal 4, assigns(:pagination).current_page_number
	end


	def test_page_param_change_missing_param
		get :page_param, :diff_param_fake => 4

		assert_equal 1, assigns(:pagination).current_page_number
	end

	def test_page_param_change_over_param
		get :page_param, :diff_param => 18

		assert_equal 5, assigns(:pagination).current_page_number
	end

	# This is the inverse page order lookup. This finds the page number given an item object
	def test_page_number_for_item
		get :list, :page => 1

		p = assigns(:pagination)

		ordered = []
		# page 1
		ordered << User.find(:all, :order => 'last, first, middle, age DESC, height DESC', :limit => 5 )
		assert_equal 5, p.count_pages
		# page 2
		ordered << User.find(:all, :order => 'last, first, middle, age DESC, height DESC', :limit => 5, :offset => 5 )
		assert_equal 5, p.count_pages
		# page 3
		ordered << User.find(:all, :order => 'last, first, middle, age DESC, height DESC', :limit => 5, :offset => 10 )
		assert_equal 5, p.count_pages
		# page 4
		ordered << User.find(:all, :order => 'last, first, middle, age DESC, height DESC', :limit => 5, :offset => 15 )
		assert_equal 5, p.count_pages
		# page 5
		ordered << User.find(:all, :order => 'last, first, middle, age DESC, height DESC', :limit => 5, :offset => 20 )

		ordered.each_with_index do |items,index|
			items.each do |item|
				assert_equal index + 1, p.page_number_of_item( item )
			end
		end

		# ensure that there are still 5 pages of results
		assert_equal 5, p.count_pages
	end

# Allow for custom sorting. Ensure that the requested sort order matches what we'd get with an Active Record sort
	def test_good_custom_sort
		get :custom_sort, :order => '+age,-height,+last,-first'

		p = assigns(:pagination)
		items = []
		items.concat p.items_on_page(1)
		items.concat p.items_on_page(2)
		items.concat p.items_on_page(3)
		items.concat p.items_on_page(4)
		items.concat p.items_on_page(5)

		ordered = User.find(:all, :order => 'age, height DESC, last, first DESC' )
		ordered.each_with_index do |o,i|
			assert_equal o, items[i]
		end
	end

# We're going to behave like a hacker. We're going to try to exploit custom sorting for this model ^_^
	def test_evil_custom_sort
		get :custom_sort, :order => '+last,-first,+password'
		assert_raises( CW::Pagination::InvalidColumnName ) {
			assigns(:pagination).items_for_current_page
		}
	end

	def test_filtered_results
		get :ordered_filtered_results, :order => '+age,-height,+last,-first', :filter => 'o'

		p = assigns(:pagination)
		items = []
		items.concat p.items_on_page(1)
		items.concat p.items_on_page(2)
		items.concat p.items_on_page(3)

		ordered = User.find(:all, :order => 'age, height DESC, last, first DESC', :conditions => ['lower(last) like ?','%o%'] )
		assert !ordered.empty?
		ordered.each_with_index do |o,i|
			assert_equal o, items[i]
		end
	end


	def test_explicitly_allowed_columns
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'User', CW::SortOrder.new + 'last' + 'first' + 'middle' - 'age' - 'height', {}, 5 )
		@pagination.add_join_accessor 'first', Proc.new{|o| o.first}
		assert_equal ['first'], @pagination.explicitly_allowed_columns

# This needs work: FIXME
# Need test of join
	end



	def test_order_with_condition
		# get all with age = 22
		age = 22
		get :age_equals, :age => age

		sample_user = User.find(14)
		assert_equal age, sample_user.age #ensure have same age
		assert_equal 3, assigns(:pagination).item_number( sample_user )
		assert_equal 1, assigns(:pagination).page_number_of_item( sample_user )
	end


end

