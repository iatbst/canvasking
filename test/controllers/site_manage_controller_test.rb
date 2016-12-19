require 'test_helper'

class SiteManageControllerTest < ActionController::TestCase
  test "should get list_users" do
    get :list_users
    assert_response :success
  end

end
