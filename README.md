# CoupleGifted

カップル・夫婦向けのライフプラットフォーム。このプロジェクトはTDD（テスト駆動開発）を採用しています。

## 開発者向け

Claude Code を使って開発する場合は CLAUDE.md を参照してください。

- [CLAUDE.md](./CLAUDE.md) : プロジェクト全体の開発規約・Git ルール
- [backend/CLAUDE.md](./backend/CLAUDE.md) : バックエンド固有の規約・TDD 手順・コマンド

## 環境構築

### 起動・停止

```bash
docker compose build
docker compose up -d
docker compose down
```

### DB作成・マイグレーション

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

### RuboCop

```bash
# チェックのみ
docker compose exec api bundle exec rubocop

# 自動修正
docker compose exec api bundle exec rubocop -a
```
