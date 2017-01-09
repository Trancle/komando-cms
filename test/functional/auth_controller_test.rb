require 'test_helper'

class AuthControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "basic_index" do
		get :index
		assert_response :success
  end
  test "basic_login" do
		get :index
		assert_response 405
  end
end
