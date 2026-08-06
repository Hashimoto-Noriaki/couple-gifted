# CoupleGifted

交際中から結婚後までのふたり向けライフプラットフォーム。「パートナーが喜ぶ」を軸に、
デートスポットを決めて、記録し、次に活かすことに特化する（プレゼント・コスメ等は構想止まりで本フェーズはスコープ外）。

`backend`（Rails APIモード）と`frontend`（Next.js）のモノレポ構成。

このファイルは横断ルールのみを置く。スタック固有の詳細は `backend/CLAUDE.md` / `frontend/CLAUDE.md` を参照。

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

- **TDD**：Specを先に書いてから実装する
- **スキーマファースト**：エンドポイントを追加・変更するときは、先に`doc/api-design.md`（将来的には`openapi.yaml`）を更新してから実装する。フロント・バック双方とも、ここに無いエンドポイントを先に実装しない
- Controllerは薄く。ロジックはModel（将来的にServiceが必要になったら導入）に書く
- N+1クエリを放置しない

## Git・コミット

- トランクベース。`master`が唯一のメインブランチ
  - ※CI（`backend/.github/workflows/ci.yml`）に`develop`向けpushトリガーが残っているが、実運用は`master`への直PRになっている。要整理（別チケット）
- コミットは機能・テスト・設定ごとに細かく分ける
- プレフィックス: `feat` / `test` / `fix` / `chore` / `refactor` / `docs`
- テストだけの変更は`test:`、実装込みは`feat:`
- ファイルはできる限りジェネレータ（`rails generate`等）で作る。マイグレーションも直接作成しない

## PR

- PRタイトルもコミットと同じプレフィックス規則に従う
- **CodeRabbitのレビューを確認してからマージする**（`.coderabbit.yaml`にドメインルールを踏まえたレビュー観点を設定済み）
- Request SpecとControllerはセットで1つのPRにする（Specだけだと CI が失敗するため）
- マージ前に `/code-review`、セキュリティが気になる変更は `/security-review` も実行する

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
docker compose up -d          # backend起動
docker compose exec api bash  # コンテナに入る
docker compose down           # 停止
```

詳しいコマンドは `backend/CLAUDE.md` を参照。
