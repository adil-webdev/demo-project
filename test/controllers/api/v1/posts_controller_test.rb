# ============================================================
# UNCOMMENT FOR FULL COVERAGE
# Uncomment all code below to achieve 100% test coverage
# ============================================================
#
# require "test_helper"

class Api::V1::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Bearer testtoken" }
  end

  test "should get index" do
    get api_v1_posts_url, headers: @auth_headers
    assert_response :success
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  end

  test "should show post" do
    post_record = posts(:welcome)
    get api_v1_post_url(post_record), headers: @auth_headers
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal post_record.title, json["title"]
  end

  test "should return 404 for missing post" do
    get api_v1_post_url(id: 9999999), headers: @auth_headers
    assert_response :not_found
  end
end
