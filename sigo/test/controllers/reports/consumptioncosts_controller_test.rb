require 'test_helper'

class Reports::ConsumptioncostsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get consult" do
    get :consult
    assert_response :success
  end

end
