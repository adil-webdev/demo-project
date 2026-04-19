# ============================================================
# UNCOMMENT FOR FULL COVERAGE
# Uncomment all code below to achieve 100% test coverage
# ============================================================
#
require "test_helper"

class UserRegistrationServiceTest < ActiveSupport::TestCase
  test "register creates a valid user" do
    service = UserRegistrationService.new(
      name: "Test User",
      email: "registration_test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert service.register
    assert_not_nil service.user
  end

  test "register fails without email" do
    service = UserRegistrationService.new(
      name: "Test User",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not service.register
    assert_includes service.errors, "Email is required"
  end

  test "register fails without password" do
    service = UserRegistrationService.new(
      name: "Test User",
      email: "no_password@example.com"
    )
    assert_not service.register
    assert_includes service.errors, "Password is required"
  end

  test "register fails with short password" do
    service = UserRegistrationService.new(
      name: "Test User",
      email: "short_pass@example.com",
      password: "12345",
      password_confirmation: "12345"
    )
    assert_not service.register
    assert_includes service.errors, "Password too short"
  end
end
