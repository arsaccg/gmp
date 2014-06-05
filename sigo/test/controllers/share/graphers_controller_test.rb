require 'test_helper'

class Share::GraphersControllerTest < ActionController::TestCase
  test "should get paint" do
    get :paint
    assert_response :success
  end

end
