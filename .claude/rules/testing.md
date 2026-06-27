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

## 将来の検討：BDD（Behavior-Driven Development）

現在は TDD（テスト駆動開発）を採用しているが、将来的に BDD の導入を検討している。

### BDD とは

BDD は TDD を発展させた手法で、**ビジネス要件をシナリオとして記述**し、それをテストに落とし込む。
非エンジニア（PO・デザイナー）も読めるテストを書くことで、仕様の認識ズレを防ぐ。

### 候補ツール

| ツール | 用途 |
|--------|------|
| RSpec + Capybara | Rails の統合テスト（E2E に近い） |
| Cucumber | Gherkin 記法（Given / When / Then）でシナリオを記述 |
| Playwright（既存） | フロントエンドの E2E は現在これを使用 |

### Gherkin 記法イメージ

```gherkin
Feature: プレゼント提案
  Scenario: パートナーへのプレゼントを検索する
    Given ユーザーがログインしている
    When  "プレゼント" カテゴリを選択する
    Then  おすすめのプレゼント一覧が表示される
```

### 導入タイミングの目安

- チームメンバーが増え、非エンジニアが仕様レビューに参加するようになった時点で再検討する
- 現状は TDD で十分なため、導入を急がない
