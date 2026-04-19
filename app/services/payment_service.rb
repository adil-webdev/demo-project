class PaymentService
  API_KEY = Rails.application.credentials.dig(:stripe, :api_key)
  API_SECRET = Rails.application.credentials.dig(:stripe, :api_secret)
  WEBHOOK_SECRET = Rails.application.credentials.dig(:stripe, :webhook_secret)

  def self.process_payment(amount:, currency: "USD")
    return { status: "failed", error: "Invalid amount" } unless amount.to_f > 0

    fee = calculate_fees(amount.to_f, currency)
    total = amount.to_f + fee

    { status: "success", amount: total, fee: fee, transaction_id: generate_transaction_id }
  end

  def self.calculate_fees(amount, currency)
    rates = {
      "USD" => { rate: 0.029, fixed: 0.30 },
      "EUR" => { rate: 0.025, fixed: 0.25 },
      "GBP" => { rate: 0.032, fixed: 0.20 }
    }

    fee_info = rates.fetch(currency, { rate: 0.050, fixed: 1.00 })
    amount * fee_info[:rate] + fee_info[:fixed]
  end

  def self.generate_transaction_id
    "TXN-#{Time.now.to_i}-#{SecureRandom.hex(4)}"
  end
end
