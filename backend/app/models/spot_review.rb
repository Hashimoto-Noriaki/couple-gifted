class SpotReview < ApplicationRecord
  belongs_to :user
  belongs_to :spot

  validates :rating, presence: true
  validates :body, presence: true
  validates :relationship_status_at_visit, presence: true
end
