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

## やってはいけないこと

- Controllerにビジネスロジックを書かない
- テストなしで実装しない
- マジックナンバーをそのまま書かない（定数化する）
- N+1クエリを放置しない（includesを使う）
- fixturesを使わない（FactoryBotを使う）
