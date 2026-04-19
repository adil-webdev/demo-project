# ============================================================
# UNCOMMENT FOR FULL COVERAGE
# Uncomment all code below to achieve 100% test coverage
# ============================================================
#
require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:john)
    @admin = users(:admin)
    @post = posts(:welcome)
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get show" do
    get post_url(@post)
    assert_response :success
  end

  test "filter action returns posts" do
    get filter_posts_url(status: "published")
    assert_response :success
  end

  test "should redirect new when not logged in" do
    get new_post_url
    assert_redirected_to root_path
  end

  test "should get new when logged in" do
    post login_url, params: { email: @user.email, password: "password123" }
    get new_post_url
    assert_response :success
  end

  test "should create post when logged in" do
    post login_url, params: { email: @user.email, password: "password123" }
    assert_difference("Post.count") do
      post posts_url, params: { post: { title: "A New Test Post", content: "Test content here", status: "draft" } }
    end
    assert_redirected_to post_url(Post.last)
  end

  test "should update own post" do
    post login_url, params: { email: @user.email, password: "password123" }
    user_post = posts(:code_quality)
    patch post_url(user_post), params: { post: { title: "Updated Title Here" } }
    assert_redirected_to post_url(user_post)
  end

  test "should destroy own post" do
    post login_url, params: { email: @user.email, password: "password123" }
    user_post = posts(:code_quality)
    assert_difference("Post.count", -1) do
      delete post_url(user_post)
    end
    assert_redirected_to posts_path
  end
end
