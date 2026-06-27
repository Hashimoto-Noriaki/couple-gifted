class Like < ApplicationRecord
  belongs_to :user
  belongs_to :spot_review

  validates :user_id, uniqueness: { scope: :spot_review_id }
end
