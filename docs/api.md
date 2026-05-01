# APIエンドポイント設計

## 認証

POST   /api/v1/auth/sign_up
POST   /api/v1/auth/sign_in
DELETE /api/v1/auth/sign_out

## スポット

GET    /api/v1/spots           # ?tag=&area=&scene=
GET    /api/v1/spots/:id

## タグ

GET    /api/v1/tags

## 口コミ

GET    /api/v1/spots/:id/spot_reviews
POST   /api/v1/spots/:id/spot_reviews   # 要認証
DELETE /api/v1/spot_reviews/:id         # 要認証・本人のみ

## いいね

POST   /api/v1/spot_reviews/:id/likes   # 要認証
DELETE /api/v1/spot_reviews/:id/likes   # 要認証

## 規約

- エンドポイントは /api/v1/ から始める
- レスポンスは必ずSerializerを通す
- 認証必須のエンドポイントは before_action :authenticate_v1_user! を明示
- エラーレスポンスは { error: "メッセージ" } で統一
