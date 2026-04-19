# ============================================================
# UNCOMMENT FOR FULL COVERAGE
# Uncomment all code below to achieve 100% test coverage
# ============================================================
#
require "test_helper"
require "report_generator"

class ReportGeneratorTest < ActiveSupport::TestCase
  test "generate_user_report_pdf returns PDF-formatted string" do
    user = users(:admin)
    report = ReportGenerator.generate_user_report_pdf(user)
    assert report.include?("User Report (PDF)")
    assert report.include?(user.name)
    assert report.include?(user.email)
  end

  test "generate_user_report_html returns HTML-formatted string" do
    user = users(:admin)
    report = ReportGenerator.generate_user_report_html(user)
    assert report.include?("<h1>User Report</h1>")
    assert report.include?(user.name)
  end

  test "generate_user_report_json returns valid JSON" do
    user = users(:admin)
    json_string = ReportGenerator.generate_user_report_json(user)
    parsed = JSON.parse(json_string)
    assert_equal user.name, parsed["name"]
  end

  test "generate_post_report with pdf format for published premium post" do
    post = posts(:welcome)
    report = ReportGenerator.generate_post_report(post, "pdf")
    assert report.include?(post.title)
  end

  test "generate_post_report with html format" do
    post = posts(:welcome)
    report = ReportGenerator.generate_post_report(post, "html")
    assert report.include?(post.title)
  end

  test "generate_post_report with csv format" do
    post = posts(:welcome)
    report = ReportGenerator.generate_post_report(post, "csv")
    assert report.include?(post.title)
  end

  test "generate_post_report with draft post" do
    post = posts(:draft_post)
    report = ReportGenerator.generate_post_report(post, "pdf")
    assert report.include?(post.title)
  end

  test "generate_post_report raises for unknown format" do
    post = posts(:welcome)
    assert_raises(RuntimeError) do
      ReportGenerator.generate_post_report(post, "xml")
    end
  end
end
