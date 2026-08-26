---
paths:
  - "backend/**/*"
---

# backend（Rails API）ルール

横断ルールは `../../CLAUDE.md` を参照。ここはRails固有かつ、そこに書いていない差分のみを扱う。

## 技術スタックの前提

- バージョンは`Gemfile`・`.ruby-version`を正とする（ここには書かない。ドリフト防止）
- DBはSQLite3（DBコンテナ無し）。PostgreSQLは本番候補として検討中だが未確定。「PostgreSQL前提」のコードを書かない
- 認証方式・レスポンスのシリアライズ方式は未決定（Gemfileに該当gemなし）。devise_token_auth・jsonapi-serializer等を導入すると、この場で断定しない。導入する際は`doc/api-design.md`・`doc/api/openapi.yaml`と`Gemfile`を先に更新してから実装する（スキーマファーストの原則）
- 外部API連携（Google Places API等）は`doc/`に記載がない限り前提にしない。使う場合はまず`doc/`に根拠を残す

## 開発の進め方（Railsに固有の部分）

- **TDD**：RSpecでSpecを先に書いてから実装する（FactoryBot・shoulda-matchers使用）。Request SpecとControllerを1PRにまとめる理由は`.claude/rules/git.md`参照
- fixturesは使わない（FactoryBotを使う）

## ドメインルール（`doc/domain-model.md`が正本）

`doc/domain-model.md`のSTEP5「技術の都合で歪めてはいけない判断」はリファクタリング対象にしない。特に以下は実装・レビュー時に必ず踏まえる。
**`.coderabbit.yaml`のpath_instructionsと同内容。`doc/domain-model.md`かこちらを変更したら、もう一方と`.coderabbit.yaml`も直す（3箇所を同期させる）。**

**Model**

- レビュー（Review）は投稿時点の`relationship_stage`をコピーして保持する。会員の現在のステージから動的に算出・表示しない（過去のレビューが書き換わってしまうため、意図的な非正規化）
- スポットの平均評価は「1組のカップル/会員につき、1スポットあたり最新1件」のみを集計する。全レビューの単純平均にしない
- 保存（Save）の「共有」→「サプライズ」への逆方向の変更は許可しない（不可逆の仕様。窓口自体を作らない）
- 招待コードが使えない理由（期限切れ／使用済み／発行者の状態など）を区別して返さない。区別すると総当たりの手がかりになるため、理由は常に一様なエラーにする
- 招待コードは1会員につき常に有効なものが1つだけ。再発行時に旧コードを無効化する
- カップルの連携解除は「片方の意思のみ」でできる。相手の承認を要求する実装にしない

**Controller（可視性・認可）**

- 下書きレビューは本人と管理者以外に見えてはならない
- サプライズ保存はパートナーから「一覧に出ない／詳細を開けない／検索結果に出ない／件数にも数えない／存在自体が伝わらない」を満たす。一部だけ隠して件数や存在が漏れる実装にしない
- 通報は投稿者に伝わってはならない
- 管理操作（削除・停止など）は実行者・日時・内容・理由を記録する

**Spec**

- 「見えないこと」を確認するテスト（サプライズ保存がパートナーから一切見えない、下書きレビューが他人から見えない等）を、正常系だけでなく否定的なケースとして書く

## API規約

- エンドポイントは`/api/v1/`から始める（`doc/api-design.md`のエンドポイント一覧に準拠）
- エラーレスポンスは**RFC 9457（Problem Details）**で統一する（`doc/api-design.md`で決定済み）。`{ error: "..." }`のような独自形式にしない
  - 例外：招待コードのエラーは理由を区別せず常に同じ`type`を返す（総当たり対策、決定事項）
- HTTPステータスコードはセマンティクスに従う（200 / 201 / 204 / 400 / 401 / 403 / 404 / 409 / 422 / 500）
- レスポンスはControllerで直接ハッシュを組み立てず、何らかのSerializer層を経由させる。`app/serializers/`配下の素のRubyクラス（`#as_json`を持つPORO）を使う。jbuilder・jsonapi-serializer等のgemは未導入（導入する場合は`doc/`へ根拠を残してから決める）
- `doc/api/openapi.yaml`をSSoTとし、`committee-rails`gemでリクエスト／レスポンスをスキーマ検証する（`spec/rails_helper.rb`に設定済み）。Request Specでは`assert_schema_conform`を使う
  - `committee_options`の`prefix: '/api/v1'`は必須（`openapi.yaml`の`servers.url`はcommitteeが自動参照しないため）。無いと全リクエストが`undefined in schema`で失敗する
  - ⚠️未整備：CIでスキーマと実装のドリフトを検知する仕組みは無い（手元で`bundle exec rspec`を通す運用）
- `doc/api/openapi.yaml`は`/api-docs`（Swagger UI、`rswag-ui`gem）でも閲覧できる。`/api/v1/`配下ではないため上記のRFC 9457等のドメイン規約対象外（管理画面と同じ扱い）
  - HTTPエンドポイントとしての公開はdevelopment限定（`config/routes.rb`・`config/initializers/rswag_ui.rb`は`Rails.env.development?`で分岐）。認証機構が未実装のため、本番公開するとAPIスキーマ全体が誰でも閲覧できてしまう
  - `doc/api/openapi.yaml`を生ファイルのまま返すだけ（`app/controllers/api_docs_controller.rb`）。パスは`config/initializers/openapi.rb`で一元管理し、`spec/rails_helper.rb`のcommittee_optionsと共有する（SSoTは変わらず`doc/api/openapi.yaml`）
  - gem自体は`group :development, :test`（`Gemfile`）。testグループにも含めるのは、`spec/requests/api_docs_spec.rb`で`Rails.env`をdevelopmentに見せかけてルーティングを検証するため（HTTP公開範囲とは別の話）

## 管理画面（APIを経由しない）

`/api/v1/`配下に管理者向けAPI（窓口）を作らない（`doc/api-design.md`決定事項ログ #30・#31）。管理画面はAPIを経由せず、Railsの通常のController/View（ERB）で作る。

- ルーティング・Controllerは`app/controllers/admin/`のような別namespaceにする（`api/v1/`配下に混ぜない）
- レスポンスはJSONではなくHTML（ERB）。上記のRFC 9457・Serializerのルールは対象外（それはNext.js向けAPIの契約であり、社内運営ツールには適用しないと決定済み）
- `doc/api-design.md`・`doc/api/openapi.yaml`への追記も不要（API-firstはクライアント-サーバー契約に関する方針で、運営ツールには適用しない）
- 認証はメンバー向けAPI認証とは別（未着手）

## コーディング規約（Railsに固有の部分）

- N+1は`includes`/`preload`で解消する
- マジックナンバーは定数化する
- コミット前に`bundle exec rubocop -a`（safeな自動修正のみ）を通す。unsafeな修正は人が確認して個別に適用する

## Docker（SQLite3、DBコンテナ無し）

```bash
HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose up -d --build  # 起動（初回・ホストのUID/GID指定）
docker compose exec api bash                  # コンテナに入る
docker compose exec api bin/rails db:migrate
docker compose exec api bundle exec rspec
docker compose exec api bin/rails console
docker compose logs -f api
docker compose down
```

- `bin/rails`を直接叩くコマンドは`RAILS_ENV`が development になる点に注意（`spec/rails_helper.rb`側でtestは固定済みなのでrspec実行時は問題ない）

## Lint・セキュリティ

⚠️`backend/.github/workflows/ci.yml`はリポジトリルートの`.github/workflows/`ではない場所に置かれているためGitHub Actionsに認識されず、実行履歴0件（未整備。`.claude/rules/git.md`参照）。**CIでは自動実行されない**ため、コミット前に手元で実行する。

- `bin/rubocop -f github`（rubocop-rails-omakase）
- `bin/brakeman --no-pager`
- `bin/bundler-audit`

## つまずきやすい点

- Request Specが全部403（Blocked hosts）になる場合、`config/environments/test.rb`の`config.hosts`ではなく
  `RAILS_ENV`を疑う。`docker-compose.yml`はコンテナ全体に`RAILS_ENV=development`を設定しているため、
  `spec/rails_helper.rb`が`ENV['RAILS_ENV'] ||= 'test'`のままだとdevelopment設定（`config.hosts`のdefault
  許可リストにテスト時のHostが含まれない）でRequest Specが動いてしまう。`ENV['RAILS_ENV'] = 'test'`と
  強制上書きする（設定済み）
- `doc/api/openapi.yaml`は`openapi: 3.0.3`で書く。`committee` gem（5.6.3時点）がOpenAPI 3.1系に未対応
  （`Committee::OpenAPI3Unsupported`で例外になる）ため
- `doc/`はコンテナ内で`/doc`（`/rails`ではなくコンテナルート直下、read-only）。`Rails.root.join('..', 'doc', ...)`で参照する
  （`docker-compose.yml`の`./doc:/doc:ro`マウント、`spec/rails_helper.rb`の`committee_options`参照）
