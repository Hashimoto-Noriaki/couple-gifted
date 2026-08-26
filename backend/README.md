# couple-gifted backend

Ruby on Rails製のバックエンドAPI。

## Getting Started

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server
```

## Swagger UI

`doc/api/openapi.yaml`（APIスキーマの正本）をブラウザから確認できます。認証機構が未実装のため、development環境限定です。

サーバー起動後（`bin/rails server`、またはDocker利用時は`docker compose up -d --build`）、以下にアクセスしてください。

- Swagger UI: http://localhost:3000/api-docs
- 生YAML: http://localhost:3000/api-docs/openapi.yaml

## Test

[RSpec](https://rspec.info) を使用しています。

```bash
bundle exec rspec
```

## Lint & Format

[Rubocop](https://github.com/rubocop/rubocop)（Omakase設定）を使用しています。

```bash
# チェックのみ
bundle exec rubocop

# 自動修正（安全な修正のみ）
bundle exec rubocop -a

# 自動修正（安全でない修正も含む）
bundle exec rubocop -A
```
