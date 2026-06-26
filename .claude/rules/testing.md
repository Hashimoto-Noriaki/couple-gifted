# テスト方針

## TDD の手順（この順番を必ず守る）

1. Model Spec（バリデーション・アソシエーション）
2. Model 実装（Spec を通す）
3. Request Spec（エンドポイントのテストを先に書く）
4. Controller 実装（Spec を通す）
5. 必要なら Service クラスに切り出す

## Spec の書き方（RSpec）

- FactoryBot でテストデータを作る（fixtures 禁止）
- `describe` / `context` は日本語 OK
- `shared_examples` で重複を減らす
- `let` でデータ定義を明示的に書く

## 認証ありエンドポイントのテストパターン

```ruby
let(:user) { create(:user) }
let(:auth_headers) { user.create_new_auth_token }

before { post '/api/v1/...', headers: auth_headers }
```
