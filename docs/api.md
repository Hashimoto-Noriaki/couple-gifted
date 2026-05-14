# APIエンドポイント設計

## 認証

POST   /auth           # ユーザー登録（devise_token_auth）
POST   /auth/sign_in
DELETE /auth/sign_out

## スポット

GET    /api/v1/spots           # ?tag=&area=
GET    /api/v1/spots/:id

## タグ（未実装）

GET    /api/v1/tags

## 口コミ（未実装）

GET    /api/v1/spots/:id/spot_reviews
POST   /api/v1/spots/:id/spot_reviews   # 要認証
DELETE /api/v1/spot_reviews/:id         # 要認証・本人のみ

## いいね（未実装）

POST   /api/v1/spot_reviews/:id/likes   # 要認証
DELETE /api/v1/spot_reviews/:id/likes   # 要認証

## スキーマ管理

- `api/openapi.yaml` で OpenAPI 3.0 形式で管理する
- スキーマファーストで進める。エンドポイントを追加・変更するときは先にスキーマを更新する

## 規約

- エンドポイントは /api/v1/ から始める
- レスポンスは必ずSerializerを通す
- 認証必須のエンドポイントは before_action :authenticate_v1_user! を明示
- エラーレスポンスは { error: "メッセージ" } で統一
