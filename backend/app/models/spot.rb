class Spot < ApplicationRecord
  belongs_to :area
  belongs_to :category

  # doc/er-and-db-design.md：削除しない。レビューが付いている場合はunpublishedに切り替える
  enum :status, { published: 0, unpublished: 1 }

  validates :name, presence: true
  validates :address, presence: true
  validates :lat, numericality: true, allow_nil: true
  validates :lng, numericality: true, allow_nil: true
  validates :reviews_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :rating_average,
    numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 },
    allow_nil: true

  # ゲストでも検索・閲覧できるのは公開中のスポットのみ（doc/domain-model.md）
  scope :published, -> { where(status: :published) }

  # doc/api-design.md「設計上の判断 5」：一覧はカーソルページネーション。
  # created_at降順で並べ、同時刻の同着はidで一意に順序付けする（keyset pagination）。
  CURSOR_ORDER = { created_at: :desc, id: :desc }.freeze
  private_constant :CURSOR_ORDER

  scope :ordered_for_listing, -> { order(CURSOR_ORDER) }

  scope :after_cursor, lambda { |created_at, id|
    where(
      "spots.created_at < :created_at OR (spots.created_at = :created_at AND spots.id < :id)",
      created_at: created_at, id: id
    )
  }

  def self.decode_cursor(cursor)
    return nil if cursor.blank?

    # cursorはクライアントの入力（配列・Hash等も送られ得る）。Base64.urlsafe_decode64は
    # String以外だとArgumentErrorではなくNoMethodErrorを送出するため、先に型を確認する
    raise ArgumentError, "cursorが不正です" unless cursor.is_a?(String)

    encoded_created_at, id = Base64.urlsafe_decode64(cursor).split("|", 2)
    # セパレータ「|」が無い壊れたcursorは、idがnilのままafter_cursorに渡ると
    # `spots.id < NULL`（常にfalse）で同着タイブレークが黙って外れてしまうため、ここで弾く
    raise ArgumentError, "cursorが不正です" if id.blank?

    [ Time.iso8601(encoded_created_at), id ]
  rescue ArgumentError, TypeError
    raise ArgumentError, "cursorが不正です"
  end

  def self.encode_cursor(spot)
    Base64.urlsafe_encode64("#{spot.created_at.iso8601(6)}|#{spot.id}")
  end
end
