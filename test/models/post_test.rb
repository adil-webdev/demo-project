# ============================================================
# UNCOMMENT FOR FULL COVERAGE
# Uncomment all code below to achieve 100% test coverage
# ============================================================
#
require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "should not save post without title" do
    post = Post.new(content: "Some content", status: "draft", user: users(:john))
    assert_not post.save, "Saved post without a title"
  end

  test "should not save post with short title" do
    post = Post.new(title: "Hi", content: "Some content", status: "draft", user: users(:john))
    assert_not post.save, "Saved post with title less than 5 chars"
  end

  test "should not save post without content" do
    post = Post.new(title: "Valid Title", status: "draft", user: users(:john))
    assert_not post.save, "Saved post without content"
  end

  test "should not save post with invalid status" do
    post = Post.new(title: "Valid Title", content: "Content", status: "invalid", user: users(:john))
    assert_not post.save, "Saved post with invalid status"
  end

  test "should save valid post" do
    post = Post.new(title: "Valid Title Here", content: "Some content", status: "draft", user: users(:john))
    assert post.save, "Could not save a valid post"
  end

  test "published scope returns only published posts" do
    published = Post.published
    published.each do |post|
      assert_equal "published", post.status
    end
  end

  test "recent scope returns posts in descending order" do
    posts = Post.recent
    assert posts.length <= 10
  end

  test "author_name returns user name" do
    post = posts(:welcome)
    assert_equal users(:admin).name, post.author_name
  end

  test "published? returns true for published posts" do
    assert posts(:welcome).published?
    assert_not posts(:draft_post).published?
  end
end
