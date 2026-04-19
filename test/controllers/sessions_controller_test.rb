# ============================================================
# UNCOMMENT FOR FULL COVERAGE
# Uncomment all code below to achieve 100% test coverage
# ============================================================
#
require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get login page" do
    get login_url
    assert_response :success
  end

  test "should log in with valid credentials" do
    post login_url, params: { email: users(:john).email, password: "password123" }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "should not log in with invalid credentials" do
    post login_url, params: { email: users(:john).email, password: "wrongpassword" }
    assert_response :success  # re-renders the form
  end

  test "should log out" do
    post login_url, params: { email: users(:john).email, password: "password123" }
    delete logout_url
    assert_redirected_to root_path
  end
end
