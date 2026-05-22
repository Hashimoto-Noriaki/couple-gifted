# CoupleGifted

カップル・夫婦向けのライフプラットフォーム。このプロジェクトはTDD（テスト駆動開発）を採用しています。

## 開発者向け

Claude Code を使って開発する場合は CLAUDE.md を参照してください。

- [CLAUDE.md](./CLAUDE.md) : プロジェクト全体の開発規約・Git ルール
- [backend/CLAUDE.md](./backend/CLAUDE.md) : バックエンド固有の規約・TDD 手順・コマンド

## 環境構築

### 起動・終了

```bash
# ビルド
docker compose build

# 起動
docker compose up -d

# 停止（コンテナ保持）
docker compose stop

# 終了（コンテナ・ネットワーク削除）
docker compose down
```

### DB作成・マイグレーション

`docker compose up -d` でコンテナを起動した後に実行してください。

```bash
docker compose exec api bin/rails db:create
docker compose exec api bin/rails db:migrate
```

### 動作確認

```bash
curl http://localhost:3000
# => http://localhost:3000
```

## 開発コマンド

### RSpec

```bash
# 全件実行
docker compose exec api bundle exec rspec

# ファイル指定
docker compose exec api bundle exec rspec spec/models/user_spec.rb

# 行番号指定
docker compose exec api bundle exec rspec spec/models/user_spec.rb:10
```

### テストDB リセット

マイグレーション追加後やテストDBが壊れたときに使用します。

```bash
docker compose exec -e RAILS_ENV=test api bin/rails db:drop db:create db:migrate
```

### RuboCop

```bash
# チェックのみ
docker compose exec api bundle exec rubocop

# 自動修正
docker compose exec api bundle exec rubocop -a
```

## フロントエンド（Next.js）

```bash
# 依存パッケージのインストール
cd frontend && pnpm install

# 開発サーバー起動（http://localhost:3001）
cd frontend && pnpm dev
```

### Vitest（フロントエンドテスト）

```bash
# ウォッチモード（開発中）
cd frontend && pnpm test

# 一回実行して終了（CI用）
cd frontend && pnpm test run
```

### 型チェック

```bash
cd frontend && pnpm run type-check
```

### Biome（Lint / Format）

```bash
# Lint チェック
cd frontend && pnpm lint

# フォーマット（自動修正）
cd frontend && pnpm format

# Lint + Format まとめてチェック（CI 用）
cd frontend && pnpm exec biome check .

# Lint + Format まとめて自動修正
cd frontend && pnpm exec biome check --write .
```
