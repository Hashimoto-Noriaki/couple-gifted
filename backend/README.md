# couple-gifted backend

Ruby on Rails製のバックエンドAPI。

## Getting Started

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server
```

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
