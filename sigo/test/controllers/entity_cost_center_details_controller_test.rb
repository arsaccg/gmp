require 'test_helper'

class EntityCostCenterDetailsControllerTest < ActionController::TestCase
  test "should get :index,:show,:create,:destroy,:edit,:new,:update" do
    get ::index,:show,:create,:destroy,:edit,:new,:update
    assert_response :success
  end

end
