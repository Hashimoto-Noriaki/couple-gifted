# CoupleGifted

交際中から結婚後までのふたり向けライフプラットフォーム。「パートナーが喜ぶ」を軸に、
デートスポットを決めて、記録し、次に活かすことに特化する（プレゼント・コスメ等は構想止まりで本フェーズはスコープ外）。

`backend`（Rails APIモード）と`frontend`（Next.js）のモノレポ構成。

このファイルは横断ルールのみを置く。スタック固有の詳細は `.claude/rules/backend.md`（Rails）/ `.claude/rules/frontend.md`（Next.js）を参照。

## リポジトリ構成

- `backend/` : Ruby on Rails 8.1（APIモード）
- `frontend/` : Next.js 16.2
- `doc/` : 要件・ドメイン・ER・API設計などのドキュメント

## ドキュメント

実装やレビューで仕様・用語に迷ったら、まず `doc/` を見る。ここにない方針を
「このプロジェクトの方針」として断定しない。

| ドキュメント | 内容 |
| --- | --- |
| `doc/requirements.md` | 要件定義。スコープ内/外の判断根拠 |
| `doc/user-stories.md` / `doc/use-cases.md` | ユーザーストーリー・ユースケース |
| `doc/domain-model.md` | 対象物・動詞・守るべきルール。「技術の都合で歪めてはいけない判断」を含む |
| `doc/ubiquitous-language.md` | 用語の統一。使わないと決めた言葉も載っている |
| `doc/er-and-db-design.md` | テーブル・カラム設計 |
| `doc/api-design.md` | エンドポイント設計。実スキーマは`openapi.yaml`が正本（未作成） |
| `doc/screen-flow.md` / `doc/wireframes.md` | 画面遷移・ワイヤーフレーム |

## 開発の進め方

- **TDD**：Specを先に書いてから実装する。カバレッジ方針・対象範囲の考え方は`.claude/rules/testing.md`を参照
- **スキーマファースト**：エンドポイントを追加・変更するときは、先に`doc/api-design.md`（将来的には`openapi.yaml`）を更新してから実装する。フロント・バック双方とも、ここに無いエンドポイントを先に実装しない
- Controllerは薄く。ロジックはModel（将来的にServiceが必要になったら導入）に書く
- N+1クエリを放置しない

## Git・ブランチ・PR

ブランチ命名・コミットプレフィックス・PRの進め方は `.claude/rules/git.md` を参照。

## ディレクトリ構成

- 最初は単一ファイルで始める。分割はスケールが実際に必要になってから行う
- 過剰なディレクトリ設計は禁止（例：使う予定のない先回りの分割）

## リポジトリの位置づけ

現リポジトリはPOC・MVP検証 + 非エンジニア教育の場。技術・プロセス検証が成功したら、
ここで確立した規約・ドキュメント・TDD/スキーマファーストのアプローチをテンプレートに、
プライベートリポジトリで本番運用へ移行する方針。

## ローカル開発（Docker）

backendはDocker（SQLite3、DBコンテナ無し）。frontendは今のところコンテナ化していない
（実コードがまだ薄いため。必要になったら追加する）。

```bash
HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose up -d --build  # backend起動（初回・ホストのUID/GID指定）
docker compose exec api bash                                      # コンテナに入る
docker compose down                                                # 停止
```

`HOST_UID`/`HOST_GID`はコンテナ内の実行ユーザーとホストユーザーを合わせるための指定。
`./backend:/rails`をbind mountしているため、指定しないとコンテナが作成するファイル（DB・ログ等）が
ホスト側で別ユーザー所有になる（未指定時は1000:1000にフォールバック）。

詳しいコマンドは `.claude/rules/backend.md` を参照。
