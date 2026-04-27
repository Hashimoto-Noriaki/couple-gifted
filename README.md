# TDD(テスト駆動開発を採用)

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
docker compose exec api bundle exec rails
```

- bundle install

```bash
docker compose exec api bundle install
```

### RSpecの実行コマンド

```bash
docker compose exec api bundle exec rspec

# ファイル指定                                                                     
docker compose exec api bundle exec rspec spec/models/user_spec.rb
                 
# 行番号まで指定（特定のテストだけ実行）                                           
docker compose exec api bundle exec rspec spec/models/user_specrb:10
```
