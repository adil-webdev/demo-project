# ============================================================
# UNCOMMENT FOR FULL COVERAGE
# Uncomment all code below to achieve 100% test coverage
# ============================================================
#
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index when logged in" do
    post login_url, params: { email: users(:john).email, password: "password123" }
    get users_url
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get users_url
    assert_redirected_to root_path
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { name: "New User", email: "newtest@example.com", password: "password123", password_confirmation: "password123" } }
    end
    assert_redirected_to root_path
  end

  test "should show user when logged in" do
    post login_url, params: { email: users(:john).email, password: "password123" }
    get user_url(users(:john))
    assert_response :success
  end

  test "should get profile when logged in" do
    post login_url, params: { email: users(:john).email, password: "password123" }
    get profile_user_url(users(:john))
    assert_response :success
  end

  test "should update own profile" do
    post login_url, params: { email: users(:john).email, password: "password123" }
    patch user_url(users(:john)), params: { user: { name: "Updated Name" } }
    assert_redirected_to user_url(users(:john))
  end
end
