require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "basic" do
		get :home
		assert_response :success
  end
end
