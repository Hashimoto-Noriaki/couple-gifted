# バックエンド開発規約

## 技術スタック

- Ruby 3.3 / Rails 8.0（API mode）
- PostgreSQL
- devise_token_auth（認証）
- jsonapi-serializer（レスポンス整形）
- Google Places API（スポットデータ取得）

## API 規約

- エンドポイントは `/api/v1/` から始める
- レスポンスは必ず Serializer を通す（jsonapi-serializer 以外禁止）
- 認証必須のエンドポイントは `before_action :authenticate_v1_user!` を明示
- エラーレスポンスは `{ error: "メッセージ" }` で統一
- HTTP ステータスコード: 200 / 201 / 401 / 422 / 500

## コーディング規約

- Controller は薄く。ロジックは Service / Model に書く
- N+1 禁止（`includes` を使う）
- マジックナンバーは定数化する
- ファイルは `rails generate` で生成する（手書き禁止）
- コミット前に `bundle exec rubocop -A` を通す

## やってはいけないこと

- Controller にビジネスロジックを書かない
- テストなしで実装しない
- fixtures を使う（代わりに FactoryBot を使う）
