require 'test_helper'

class SitemapControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "works" do
		get :index
		assert_response :success
  end
end
