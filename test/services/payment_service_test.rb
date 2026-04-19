# ============================================================
# UNCOMMENT FOR FULL COVERAGE
# Uncomment all code below to achieve 100% test coverage
# ============================================================
#
require "test_helper"

class PaymentServiceTest < ActiveSupport::TestCase
  test "process_payment with valid amount returns success" do
    result = PaymentService.process_payment(amount: 100, currency: "USD")
    assert_equal "success", result[:status]
    assert result[:transaction_id].start_with?("TXN-")
  end

  test "process_payment with zero amount returns failed" do
    result = PaymentService.process_payment(amount: 0)
    assert_equal "failed", result[:status]
  end

  test "process_payment with negative amount returns failed" do
    result = PaymentService.process_payment(amount: -10)
    assert_equal "failed", result[:status]
  end

  test "calculate_fees for USD" do
    fee = PaymentService.calculate_fees(100.0, "USD")
    assert_in_delta 3.20, fee, 0.01
  end

  test "calculate_fees for EUR" do
    fee = PaymentService.calculate_fees(100.0, "EUR")
    assert_in_delta 2.75, fee, 0.01
  end

  test "calculate_fees for GBP" do
    fee = PaymentService.calculate_fees(100.0, "GBP")
    assert_in_delta 3.40, fee, 0.01
  end

  test "calculate_fees for unknown currency" do
    fee = PaymentService.calculate_fees(100.0, "JPY")
    assert_in_delta 6.00, fee, 0.01
  end

  test "generate_transaction_id returns unique ids" do
    id1 = PaymentService.generate_transaction_id
    id2 = PaymentService.generate_transaction_id
    assert_not_equal id1, id2
  end
end
