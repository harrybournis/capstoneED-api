require 'test_helper'

class V1::AuthenticationsControllerControllerTest < ActionDispatch::IntegrationTest
  test "should get email" do
    get v1_authentications_controller_email_url
    assert_response :success
  end

  test "should get facebook" do
    get v1_authentications_controller_facebook_url
    assert_response :success
  end

  test "should get google" do
    get v1_authentications_controller_google_url
    assert_response :success
  end

end
