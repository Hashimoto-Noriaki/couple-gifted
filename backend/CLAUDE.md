# Backend 開発ガイド（TDD）

## 技術スタック

- Ruby 3.3 / Rails 8.0（API mode）
- PostgreSQL
- RSpec / FactoryBot / Shoulda Matchers
- devise_token_auth（認証）
- jsonapi-serializer（レスポンス整形）
- Google Places API（スポットデータ取得）

## データモデル（MVP）

| モデル     | カラム                                                        |
|------------|---------------------------------------------------------------|
| User       | email, password, nickname, gender, relationship_status        |
| Spot       | name, address, lat, lng, google_place_id                      |
| SpotReview | user_id, spot_id, rating, body, relationship_status_at_visit  |
| Like       | user_id, spot_review_id                                       |
| Tag        | name（記念日・初デート・雨の日・夫婦など）                     |
| SpotTag    | spot_id, tag_id                                               |

## APIの規約

- エンドポイントは /api/v1/ から始める
- レスポンスは必ずSerializerを通す
- 認証必須のエンドポイントは before_action :authenticate_v1_user! を明示
- エラーレスポンスは { error: "メッセージ" } で統一
- HTTPステータスコード: 200 OK / 201 Created / 401 Unauthorized / 422 Unprocessable Entity / 500 Internal Server Error

## TDDの手順（この順番を必ず守る）

1. Model Spec（バリデーション・アソシエーション）
2. Model 実装（Spec を通す）
3. Request Spec（エンドポイントのテストを先に書く）
4. Controller 実装（Spec を通す）
5. 必要ならServiceクラスに切り出す

## Specの書き方

- FactoryBotでテストデータを作る（fixtures禁止）
- describe / context は日本語OK
- shared_examplesで重複を減らす
- letを使ってデータ定義を明示的に書く

## Claude Codeへの指示の出し方

新機能を実装するときはこの順番で指示する：
1.「〇〇のModel Specを書いて」
2.「Specを通すモデルを実装して」
3.「〇〇のRequest Specを書いて」
4.「Specを通すControllerを実装して」
5.「ロジックをServiceクラスに切り出して」

## よく使うコマンド

- bundle exec rspec                # 全テスト
- bundle exec rspec spec/models    # モデルのみ
- bundle exec rspec spec/requests  # APIのみ
- bundle exec rubocop -A           # Lint自動修正
- bundle exec rails db:migrate     # マイグレーション
- bundle exec rails db:seed        # シードデータ投入

## やってはいけないこと

- Controllerにビジネスロジックを書かない
- テストなしで実装しない
- マジックナンバーをそのまま書かない（定数化する）
- N+1クエリを放置しない（includesを使う）
- fixturesを使う（代わりに FactoryBot を使う）
