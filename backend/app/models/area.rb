class Area < ApplicationRecord
  # doc/er-and-db-design.md「エリアの粒度」：市区町村より細かい単位（例：代官山、恵比寿）を
  # 上位エリア（例：渋谷エリア）の子として持たせる親子構造
  belongs_to :parent, class_name: "Area", optional: true
  has_many :children, class_name: "Area", foreign_key: :parent_id, inverse_of: :parent, dependent: :nullify
  has_many :spots, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :position, presence: true

  scope :ordered, -> { order(:position) }
end
