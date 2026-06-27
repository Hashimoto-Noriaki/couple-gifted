# 開発手順

## API開発フロー（この順番を必ず守る）

1. `docs/api.md` にエンドポイントを定義する
2. `api/openapi.yaml` にリクエスト・レスポンスのスキーマを追記する
3. バックエンドをTDDで実装する（下記「TDDの手順」参照）
4. フロントエンドを実装する（Swaggerをもとに型安全に実装）

> **なぜこの順番か**  
> openapi.yaml がフロントとバックのAPIの契約書になる。  
> 先に定義することでフロントとバックの並行開発が可能になり、後からの仕様変更を防ぐ。

## TDDの手順（この順番を必ず守る）

1. Model Spec（バリデーション・アソシエーション）
2. Model実装（Specを通す）
3. Request Spec（エンドポイントのテストを先に書く）
4. Controller実装（Specを通す）
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

## Swagger UI

`api/openapi.yaml` をブラウザで確認できる。

```bash
# 起動（http://localhost:8080）
docker compose up -d swagger
```

`openapi.yaml` を更新した場合はブラウザをリロードするだけで反映される。

## よく使うコマンド

- docker compose exec api bundle exec rspec                          # 全テスト
- docker compose exec api bundle exec rspec spec/models              # モデルのみ
- docker compose exec api bundle exec rspec spec/requests            # APIのみ
- docker compose exec api bundle exec rubocop -A                     # Lint自動修正
- docker compose exec api bundle exec rails db:migrate               # マイグレーション
- docker compose exec api bundle exec rails db:seed                  # シードデータ投入
- docker compose exec api bundle exec rails db:drop db:create db:migrate  # DBリセット（migration変更時）

## フロントエンドのテスト（Vitest）

テストファイルは `*.test.tsx` として対象コンポーネントの隣に配置する。

### コマンド

```bash
# 型チェック（CI用）
cd frontend && pnpm run type-check

# ウォッチモード（開発中）
cd frontend && pnpm test

# 一回実行して終了（CI用）
cd frontend && pnpm test run

# UIモード（ブラウザでテスト結果確認）
cd frontend && pnpm test:ui
```

### 構成

- テストフレームワーク: Vitest + jsdom
- DOMアサーション: @testing-library/jest-dom
- コンポーネント操作: @testing-library/react

## E2Eテスト（Playwright）

テストファイルは `frontend/e2e/*.spec.ts` に置く。

### E2Eコマンド

```bash
# 実行（dev サーバーを自動起動）
cd frontend && pnpm test:e2e

# インタラクティブUIモード
cd frontend && pnpm test:e2e:ui

# テストレポートを開く
cd frontend && pnpm test:e2e:report
```

### E2E構成

- テストフレームワーク: Playwright
- ブラウザ: Chromium
- baseURL: `http://localhost:3001`（Rails API の 3000 番と衝突しないよう固定）
- `webServer` 設定により `pnpm dev --port 3001` を自動起動

## 将来の検討：BDD（Behavior-Driven Development）

現在は TDD を採用しているが、将来的に BDD の導入を検討している。
詳細は `.claude/rules/testing.md` を参照。

- 候補ツール：Cucumber（Gherkin 記法）または RSpec + Capybara
- 導入タイミング：非エンジニアが仕様レビューに参加するようになった時点で再検討

## 将来の検討：BFF（Backend For Frontend）

現在は Next.js（フロントエンド）が Rails API に直接アクセスする構成だが、
認証トークンのクライアント管理や外部APIの CORS・認証複雑化が課題になった場合、
また Phase 2 以降で複数の外部API（楽天・AI）が増えるタイミングで BFF の導入を検討する。

### BFF とは

フロントエンドのために専用のバックエンド中継レイヤーを置くパターン。
複数のバックエンド・外部APIを集約し、UIに最適化したレスポンスを返す。

```bash
現在:  Next.js → Rails API
BFF後: Next.js → BFF（Hono / Next.js内マウント）→ Rails API
                                            → 楽天API
                                            → AI サービス（Phase 3）
```

### このプロジェクトで導入する動機

- Phase 2：楽天API連携でレスポンス集約が必要になる
- Phase 3：AIプレゼント診断で複数サービスをオーケストレーションする
- 認証トークンをサーバーサイドで管理することでセキュリティが向上する

### 実装方針（候補）

| 方針 | 概要 | 向いているケース |
|------|------|-----------------|
| Next.js Route Handlers | 既存スタックの延長。追加サービス不要 | シンプルな集約のみ |
| Hono（Next.js内マウント） | App Router の `app/api/[...route]/route.ts` にマウント（現構成と整合）。`hono/client` で TypeScript の型付き RPC が実現できる | 型安全性・明示的なルーティングが必要な場合 |

- Hono を別サービスとして立てると管理コストが増えるため、Next.js 内マウントを優先する
- `hono/client`（`hc<typeof app>()`）を使うと フロント↔BFF 間を TypeScript の型で縛った RPC として呼び出せる。ただし型安全性はHono アプリの型定義をフロント側で import できる場合に限られるため、モノレポ構成など型を共有できる環境が前提になる
- OpenAPI はスキーマ駆動の言語横断的な契約であり、Hono RPC の型安全性とは別の概念として使い分ける

### 導入タイミングの目安

- Phase 2（楽天API連携）開始時に再検討する
- 現状の Rails API 直接呼び出しで問題なければ見送る

## やってはいけないこと

- Controllerにビジネスロジックを書かない
- テストなしで実装しない
- マジックナンバーをそのまま書かない（定数化する）
- N+1クエリを放置しない（includesを使う）
- fixturesを使わない（FactoryBotを使う）
