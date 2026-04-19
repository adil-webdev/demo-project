# ============================================================
# UNCOMMENT FOR FULL COVERAGE
# Uncomment all code below to achieve 100% test coverage
# ============================================================
#
require "test_helper"
require "file_processor"
require "fileutils"
require "base64"
require "minitest/mock"

class FileProcessorTest < ActiveSupport::TestCase
  test "validate_file returns error for nil file" do
    result = FileProcessor.validate_file(nil)
    assert_not result[:valid]
    assert_equal "File is nil", result[:error]
  end

  test "validate_file returns error for oversized file" do
    file = Minitest::Mock.new
    file.expect :nil?, false
    file.expect :size, 20_000_000
    file.expect :size, 20_000_000
    result = FileProcessor.validate_file(file)
    assert_not result[:valid]
    assert_equal "File too large", result[:error]
  end

  test "validate_file returns error for empty file" do
    file = Minitest::Mock.new
    file.expect :nil?, false
    file.expect :size, 0
    file.expect :size, 0
    file.expect :size, 0
    result = FileProcessor.validate_file(file)
    assert_not result[:valid]
    assert_equal "File too small", result[:error]
  end

  test "validate_file returns error for invalid extension" do
    file = Minitest::Mock.new
    file.expect :nil?, false
    file.expect :size, 1000
    file.expect :size, 1000
    file.expect :size, 1000
    file.expect :original_filename, "test.exe"
    result = FileProcessor.validate_file(file)
    assert_not result[:valid]
    assert_equal "Invalid file type: .exe", result[:error]
  end

  test "validate_file returns valid for jpg" do
    file = Minitest::Mock.new
    file.expect :nil?, false
    file.expect :size, 1000
    file.expect :size, 1000
    file.expect :size, 1000
    file.expect :original_filename, "photo.jpg"
    result = FileProcessor.validate_file(file)
    assert result[:valid]
  end

  test "safe_read sanitizes filename" do
    assert_raises(RuntimeError) do
      FileProcessor.safe_read("../../etc/passwd")
    end
  end

  test "ALLOWED_EXTENSIONS includes expected types" do
    assert_includes FileProcessor::ALLOWED_EXTENSIONS, ".jpg"
    assert_includes FileProcessor::ALLOWED_EXTENSIONS, ".pdf"
    assert_includes FileProcessor::ALLOWED_EXTENSIONS, ".png"
  end
end
