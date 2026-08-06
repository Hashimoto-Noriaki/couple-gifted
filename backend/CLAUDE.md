# backend（Rails API）

横断ルールは `../CLAUDE.md` を参照。ここはRails固有の規約のみ。

## 開発の進め方

- **TDD**：RSpecでSpecを先に書いてから実装する（FactoryBot・shoulda-matchers使用）
- Request SpecとControllerはセットで1PR（Specだけだと CI が失敗する）
- **スキーマファースト**：エンドポイントの追加・変更は先に`doc/api-design.md`を更新してから実装する
- ドメインルールに迷ったら`doc/domain-model.md`を見る。特にSTEP5「技術の都合で歪めてはいけない判断」（投稿時点の関係ステージ保持、招待コードの理由を区別しない等）はリファクタリング対象にしない
- モデル・マイグレーション・コントローラは`rails generate`で作る。直接ファイルを書かない

## Docker（SQLite3、DBコンテナ無し）

```bash
docker compose up -d                          # 起動（初回はビルドも走る）
docker compose exec api bash                  # コンテナに入る
docker compose exec api bin/rails db:migrate
docker compose exec api bundle exec rspec
docker compose exec api bin/rails console
docker compose logs -f api
docker compose down
```

- DBはSQLite3。本番はPostgreSQL（Render）を検討中だが、実装が進むまでは切り替えない
- `bin/rails`を直接叩くコマンドは`RAILS_ENV`が development になる点に注意（`spec/rails_helper.rb`側でtestは固定済みなのでrspec実行時は問題ない）

## Lint・セキュリティ（CIで自動実行）

- `bin/rubocop -f github`（rubocop-rails-omakase）
- `bin/brakeman --no-pager`
- `bin/bundler-audit`

## つまずきやすい点

- Request Specが全部403になる場合、`config/environments/test.rb`の`config.hosts`を確認する
