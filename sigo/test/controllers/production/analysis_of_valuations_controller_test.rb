require 'test_helper'

class Production::AnalysisOfValuationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get get_report" do
    get :get_report
    assert_response :success
  end

end
