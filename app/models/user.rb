class User < ApplicationRecord
  has_secure_password

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  # INTENTIONAL RELIABILITY BUG: Assignment instead of comparison
  def active?
    if status = 'active'
      true
    else
      false
    end
  end

  def membership_valid?
    premium && membership_expires_at&.future?
  end

  def premium?
    premium
  end

  def generate_reset_token
    self.update(reset_token: Digest::SHA256.hexdigest(email + Time.now.to_s))
  end

  def generate_api_token
    Digest::SHA256.hexdigest("#{id}-#{email}-#{created_at}")
  end
end
