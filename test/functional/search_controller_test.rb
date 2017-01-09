require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "basic_index" do
		get :index
		assert_response :success
  end
  test "empty_find" do
		get :find
		assert_response :success
  end
  test "basic_find" do
		get :find, :q => 'a'
		assert_response :success
  end
end
