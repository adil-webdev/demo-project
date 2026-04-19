require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should not save user without name" do
    user = User.new(email: "test@example.com", password: "password123", password_confirmation: "password123")
    assert_not user.save, "Saved user without a name"
  end

  test "should not save user without email" do
    user = User.new(name: "Test User", password: "password123", password_confirmation: "password123")
    assert_not user.save, "Saved user without an email"
  end

  test "should save valid user" do
    user = User.new(name: "New User", email: "newuser@example.com", password: "password123", password_confirmation: "password123")
    assert user.save, "Could not save a valid user"
  end

  test "should enforce unique email" do
    User.create!(name: "First", email: "unique@example.com", password: "password123", password_confirmation: "password123")
    user = User.new(name: "Second", email: "unique@example.com", password: "password123", password_confirmation: "password123")
    assert_not user.save, "Saved user with duplicate email"
  end

  test "active? method returns true due to assignment bug" do
    user = users(:john)
    # This tests the intentional bug: status = 'active' (assignment) always returns true
    assert user.active?, "active? should return true due to assignment bug"
  end

  test "membership_valid? returns false for non-premium user" do
    user = users(:john)
    assert_not user.membership_valid?
  end

  test "membership_valid? returns true for premium user with future expiry" do
    user = users(:jane)
    assert user.membership_valid?
  end

  test "premium? returns correct value" do
    assert users(:admin).premium?
    assert_not users(:john).premium?
  end
end
