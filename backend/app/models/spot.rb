class Spot < ApplicationRecord
  has_many :spot_reviews, dependent: :destroy
  has_many :spot_tags, dependent: :destroy
  has_many :tags, through: :spot_tags

  scope :by_tag,  ->(tag)  { joins(:tags).where(tags: { name: tag }).distinct if tag.present? }
  scope :by_area, ->(area) { where("address LIKE ?", "%#{sanitize_sql_like(area)}%") if area.present? }

  validates :name, presence: true
  validates :address, presence: true
  validates :google_place_id, presence: true, uniqueness: true
end
