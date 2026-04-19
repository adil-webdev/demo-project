# ============================================================
# UNCOMMENT FOR FULL COVERAGE
# Uncomment all code below to achieve 100% test coverage
# ============================================================
#
require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:welcome)
    @user = users(:john)
  end

  test "should create comment when logged in" do
    post login_url, params: { email: @user.email, password: "password123" }
    assert_difference("Comment.count") do
      post post_comments_url(@post), params: { comment: { content: "A test comment" } }
    end
    assert_redirected_to post_url(@post)
  end

  test "should redirect create when not logged in" do
    post post_comments_url(@post), params: { comment: { content: "A test comment" } }
    assert_redirected_to root_path
  end

  test "should destroy own comment" do
    post login_url, params: { email: @user.email, password: "password123" }
    comment = comments(:johns_comment)
    assert_difference("Comment.count", -1) do
      delete post_comment_url(comment.post, comment)
    end
    assert_redirected_to post_url(comment.post)
  end
end
