require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "ApplicationMailer has correct default from address" do
    assert_equal "from@example.com", ApplicationMailer.default[:from]
  end

  test "ApplicationMailer inherits from ActionMailer::Base" do
    assert ApplicationMailer < ActionMailer::Base
  end
end
