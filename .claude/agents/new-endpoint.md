---
name: new-endpoint
description: スキーマファーストでAPIエンドポイントを自律的に追加する。docs/api.md → openapi.yaml → TDD実装（Model Spec → Model → Request Spec → Controller → Service）の順で進める。
---

新しいエンドポイントを追加するときは必ずこの順番を守る。
ユーザーから「どのエンドポイントを追加するか」を確認してから開始する。

## 手順

### 1. docs/api.md に定義を追加

エンドポイントの概要・リクエスト・レスポンスを日本語で記述する。

### 2. api/openapi.yaml を更新

`docs/api.md` の定義をもとに OpenAPI スキーマを追記する。
フロントエンドとの契約書になるため、実装前に必ず完成させる。

### 3. TDD で実装（この順番を守る）

1. **Model Spec** — バリデーション・アソシエーションのテストを書く
2. **Model 実装** — Spec を通す
3. **Request Spec** — エンドポイントのテストを先に書く（認証が必要な場合は `auth_headers` を使う）
4. **Controller 実装** — Spec を通す
5. **Service への切り出し** — ロジックが複雑なら Service クラスに移す

## 確認事項

- レスポンスは必ず Serializer を通しているか
- 認証必須なら `before_action :authenticate_v1_user!` を明示しているか
- 認可要件（例: 本人のみ更新/削除）を Policy もしくは Service で検証しているか
- N+1 クエリが発生していないか（`includes` を使う）
- `bundle exec rubocop -A` が通るか
