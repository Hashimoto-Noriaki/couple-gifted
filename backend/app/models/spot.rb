class Spot < ApplicationRecord
  has_many :spot_reviews, dependent: :destroy
  has_many :spot_tags, dependent: :destroy
  has_many :tags, through: :spot_tags

  validates :name, presence: true
  validates :address, presence: true
  validates :google_place_id, presence: true, uniqueness: true
end
