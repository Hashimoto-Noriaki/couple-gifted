# TDD(テスト駆動開発を採用)

## 開発者向け

Claude Code を使って開発する場合は CLAUDE.md を参照してください。

- [CLAUDE.md](./CLAUDE.md) : プロジェクト全体の開発規約・Git ルール
- [backend/CLAUDE.md](./backend/CLAUDE.md) : バックエンド固有の規約・TDD 手順・コマンド

## 環境構築

### Docker

- 起動

```bash
docker compose build
docker compose up -d
docker compose down
```

- DB作成

```bash
 docker compose exec api bundle exec rails db:create
```

- 動作確認

```bash
  curl http://localhost:3000
```

- URL

```bash
http://localhost:3000                                                              
```

### 実行コマンド

```bash
docker compose exec api bundle exec rails 〇〇
```

- bundle install

```bash
docker compose exec api bundle install
```

### RSpecの実行コマンド

```bash
# RSpecの実行
docker compose exec api bundle exec rspec

# ファイル指定                                                                     
docker compose exec api bundle exec rspec spec/models/user_spec.rb

# 行番号まで指定（特定のテストだけ実行）                                           
docker compose exec api bundle exec rspec spec/models/user_spec.rb:10
```

### RuboCopの実行コマンド

```bash
# チェックのみ
docker compose exec api bundle exec rubocop
# 自動修正
docker compose exec api bundle exec rubocop -a
```
