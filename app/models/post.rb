class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { minimum: 5 }
  validates :content, presence: true
  validates :status, inclusion: { in: %w[draft published archived] }

  scope :published, -> { where(status: "published") }
  scope :recent, -> { order(created_at: :desc).limit(10) }

  def author_name
    user.name
  end

  def published?
    status == "published"
  end
end
