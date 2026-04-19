require "test_helper"

class Admin::ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to root when not logged in" do
    get admin_reports_search_logs_url
    assert_redirected_to root_path
  end

  test "should redirect to root when logged in as regular user" do
    post login_url, params: { email: users(:john).email, password: "password123" }
    get admin_reports_search_logs_url
    assert_redirected_to root_path
  end

  test "should allow admin to search logs" do
    post login_url, params: { email: users(:admin).email, password: "admin123" }
    get admin_reports_search_logs_url, params: { query: "test" }
    assert_response :success
  end
end
