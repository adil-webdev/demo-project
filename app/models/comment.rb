class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :content, presence: true, length: { minimum: 1, maximum: 500 }

  def approved?
    status == "approved"
  end

  def pending?
    status == "pending"
  end

  def author_email
    user&.email
  end
end
