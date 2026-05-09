class SpotReview < ApplicationRecord
  belongs_to :user
  belongs_to :spot

  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5, only_integer: true }
  validates :body, presence: true
  validates :relationship_status_at_visit, presence: true
end
