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

## 口コミ

### GET /api/v1/spots/:id/spot_reviews

指定スポットの口コミ一覧を取得する。認証不要。

**レスポンス 200:**

```json
{
  "data": [
    {
      "id": "1",
      "type": "spot_review",
      "attributes": {
        "rating": 4,
        "body": "とても良いスポットでした。",
        "relationship_status_at_visit": "dating",
        "created_at": "2026-05-19T00:00:00.000Z",
        "user_nickname": "ユーザー名"
      }
    }
  ]
}
```

**エラー:**

- 404: スポットが存在しない

### POST /api/v1/spots/:id/spot_reviews

指定スポットに口コミを投稿する。認証必須。

**リクエストボディ:**

```json
{
  "rating": 4,
  "body": "とても良いスポットでした。",
  "relationship_status_at_visit": "dating"
}
```

| フィールド | 型 | 必須 | 説明 |
|---|---|---|---|
| rating | integer | yes | 評価（1〜5） |
| body | string | yes | 口コミ本文 |
| relationship_status_at_visit | string | yes | 訪問時の関係性（dating / married） |

**レスポンス 201:**

```json
{
  "data": {
    "id": "1",
    "type": "spot_review",
    "attributes": {
      "rating": 4,
      "body": "とても良いスポットでした。",
      "relationship_status_at_visit": "dating",
      "created_at": "2026-06-26T00:00:00.000Z",
      "user_nickname": "ユーザー名"
    }
  }
}
```

**エラー:**

- 401: 未認証
- 404: スポットが存在しない
- 422: バリデーションエラー

### DELETE /api/v1/spot_reviews/:id

口コミを削除する。認証必須・投稿者本人のみ削除可能。

**レスポンス 204:** ボディなし

**エラー:**

- 401: 未認証
- 403: 本人以外が削除しようとした
- 404: 口コミが存在しない

## いいね

### POST /api/v1/spot_reviews/:id/likes

指定口コミにいいねする。認証必須。同一ユーザーが同一口コミに重複していいねすることはできない。

**レスポンス 201:**

```json
{
  "likes_count": 5
}
```

**エラー:**

- 401: 未認証
- 404: 口コミが存在しない
- 409: すでにいいね済み

### DELETE /api/v1/spot_reviews/:id/likes

指定口コミのいいねを取り消す。認証必須。

**レスポンス 204:** ボディなし

**エラー:**

- 401: 未認証
- 404: 口コミが存在しない、またはいいねしていない

## スキーマ管理

- `api/openapi.yaml` で OpenAPI 3.0 形式で管理する
- スキーマファーストで進める。エンドポイントを追加・変更するときは先にスキーマを更新する

## 規約

- エンドポイントは /api/v1/ から始める
- レスポンスは必ずSerializerを通す
- 認証必須のエンドポイントは before_action :authenticate_v1_user! を明示
- エラーレスポンスは { error: "メッセージ" } で統一
