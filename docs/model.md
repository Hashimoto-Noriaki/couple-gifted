# データモデル設計

## MVP モデル一覧

User         email, password, nickname, gender, relationship_status
Spot         name, address, lat, lng, google_place_id
SpotReview   user_id, spot_id, rating, body, relationship_status_at_visit
Like         user_id, spot_review_id
Tag          name（記念日・初デート・雨の日・プロポーズ・夫婦など）
SpotTag      spot_id, tag_id

## アソシエーション

```ruby
User        has_many :spot_reviews
User        has_many :likes

Spot        has_many :spot_reviews
Spot        has_many :tags, through: :spot_tags

SpotReview  belongs_to :user
SpotReview  belongs_to :spot
SpotReview  has_many :likes

Like        belongs_to :user
Like        belongs_to :spot_review
```
