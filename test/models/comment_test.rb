# ============================================================
# UNCOMMENT FOR FULL COVERAGE
# Uncomment all code below to achieve 100% test coverage
# ============================================================
#
require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "should not save comment without content" do
    comment = Comment.new(user: users(:john), post: posts(:welcome))
    assert_not comment.save, "Saved comment without content"
  end

  test "should not save comment with content exceeding 500 chars" do
    comment = Comment.new(content: "a" * 501, user: users(:john), post: posts(:welcome))
    assert_not comment.save, "Saved comment with content exceeding limit"
  end

  test "should save valid comment" do
    comment = Comment.new(content: "A valid comment", user: users(:john), post: posts(:welcome))
    assert comment.save, "Could not save a valid comment"
  end

  test "approved? returns correct value" do
    comment = comments(:johns_comment)
    assert comment.approved?
  end

  test "pending? returns correct value" do
    comment = comments(:pending_comment)
    assert comment.pending?
  end

  test "author_email returns user email" do
    comment = comments(:johns_comment)
    assert_equal users(:john).email, comment.author_email
  end

  test "author_email returns nil when user is nil" do
    comment = Comment.new(content: "test", post: posts(:welcome))
    assert_nil comment.author_email
  end
end
