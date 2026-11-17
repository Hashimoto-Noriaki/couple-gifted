# couple-gifted

カップル・夫婦向けのライフプラットフォーム。

## ディレクトリ構成

- [`doc/`](./doc) — 要件定義・ユーザーストーリー・ユースケース・ユビキタス言語などのドキュメント
- [`frontend/`](./frontend) — フロントエンド（Next.js）。セットアップ・開発コマンドは [`frontend/README.md`](./frontend/README.md) を参照
- [`backend/`](./backend) — バックエンド（Rails API）。セットアップ・開発コマンドは [`backend/README.md`](./backend/README.md) を参照

## 開発方針

- **TDD**：Specを先に書いてから実装する
- **スキーマファースト（APIファースト）**：エンドポイントを追加・変更するときは、先に [`doc/api-design.md`](./doc/api-design.md)・[`doc/api/openapi.yaml`](./doc/api/openapi.yaml) を更新してから実装する

詳細は [`CLAUDE.md`](./CLAUDE.md) を参照。

## ドキュメント

- [要件定義](./doc/requirements.md)
- [ユーザーストーリー](./doc/user-stories.md)
- [ユースケース](./doc/use-cases.md)
- [ドメインモデル](./doc/domain-model.md)
- [ユビキタス言語](./doc/ubiquitous-language.md)
- [ER図・DB設計](./doc/er-and-db-design.md)
- [API設計](./doc/api-design.md) / [OpenAPIスキーマ](./doc/api/openapi.yaml)
- [画面遷移図](./doc/screen-flow.md) / [ワイヤーフレーム](./doc/wireframes.md)
- [Claude Codeの設定ガイド（CLAUDE.md・.claude/）](./doc/claude-code-guide.md)

## POC

https://github.com/Hashimoto-Noriaki/couple-gifted-poc

## ローカルでの起動方法（動作確認）

backend（Rails API・3000番）→ frontend（Next.js・3001番）の順に起動する。

### 1. backend（Docker）

```bash
# リポジトリルートで実行（初回・Gemfile変更時は --build を付ける）
HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose up -d --build

# 起動完了を待つ：/up が200を返すまで待つ（serverはdb:prepareの完了後に起動するため、ここを抜ければテーブルができている）
curl -o /dev/null --retry 60 --retry-delay 2 --retry-connrefused -fsS http://localhost:3000/up

# 初回のみ：動作確認用のエリア・カテゴリ・スポットを投入
docker compose exec api bin/rails db:seed
```

DBの作成・マイグレーションはコンテナ起動時に自動で行われる（`bin/rails db:prepare`）。

- Swagger UI: http://localhost:3000/api-docs
- ログを見る: `docker compose logs -f api`
- 停止: `docker compose down`

### テストを実行するには

```bash
# apiコンテナが起動中
docker compose exec api bundle exec rspec

# 起動していないとき（使い捨てのコンテナでコマンドだけを実行する）
HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose run --rm api bundle exec rspec
```

`run --rm` はRailsサーバーを起動しないため、APIを叩く確認（Swagger UI・フロントからのログイン等）には `up -d` で起動しておく必要がある。

### 2. frontend（ホストで直接起動）

```bash
cd frontend
pnpm install   # 初回・依存変更時のみ

# 初回のみ：APIのベースURLを書く（Server Componentからだけ呼ぶため NEXT_PUBLIC_ は付けない）
echo 'API_BASE_URL=http://localhost:3000/api/v1' > .env.local

pnpm dev       # http://localhost:3001
```

- スポット一覧: http://localhost:3001/spots
- ログイン: http://localhost:3001/login

### ログインを試すには

seedにはユーザーが入っていない（サインアップ画面も未実装）ので、先にAPIでユーザーを作る。
Swagger UIの`POST /api/v1/auth/sign_up`から叩くか、以下を実行する。

```bash
curl -X POST http://localhost:3000/api/v1/auth/sign_up \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","password":"password123","nickname":"テスト"}'
```

作ったメールアドレス・パスワードで http://localhost:3001/login からログインする。

#### 停止中のアカウント（403）を試すには

画面からは停止にできないので、Railsのコンソールから状態を変える。

```bash
# 停止にする
docker compose exec api bin/rails runner 'User.find_by!(email: "test@example.com").suspended!'

# 元に戻す
docker compose exec api bin/rails runner 'User.find_by!(email: "test@example.com").active!'
```

停止中に正しいパスワードでログインすると、「このアカウントは停止されています」と問い合わせ先が表示される。
