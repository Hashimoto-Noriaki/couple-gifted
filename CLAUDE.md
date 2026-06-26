# CLAUDE.md

## サービス概要

CoupleGifted（カップルギフテッド）
カップル・夫婦向けのライフプラットフォーム。
「パートナーが喜ぶ」を軸に、デートスポット・プレゼント・コスメなど
交際中から結婚後まで長く使えるサービス。

## リポジトリ構成

- backend/  : Ruby on Rails 8.0（API mode）
- frontend/ : Next.js 16.2
- api/       : OpenAPI スキーマ（openapi.yaml）

## ドキュメント

- サービス概要:   docs/overview.md
- 機能一覧:       docs/features.md
- データモデル:   docs/model.md
- API設計:        docs/api.md
- 開発手順:       docs/development.md
- チーム方針:     docs/team.md
- PRテンプレート: .github/pull_request_template.md

## 開発の大原則

- TDDで開発する。Specを先に書いてから実装する
- Controllerは薄く。ロジックはService・Modelに書く
- N+1クエリを放置しない
- スキーマファーストで進める。エンドポイントを追加・変更するときは先に `docs/api.md` でエンドポイントを定義し、`api/openapi.yaml` を更新する

## Gitルール

- トランクベース開発。`master` が唯一のメインブランチ
- ブランチ: feature/ fix/ hotfix/ refactor/ docs/ chore/（短命・1〜2日でマージ）
- コミット: feat: / fix: / hotfix: / test: / refactor: / docs: / chore:
- PRは `master` をベースに作成する
- PRを出したらCodeRabbitのレビューを確認してからマージ
- PRマージ前に `/code-review` でコードレビュー、セキュリティが気になる変更は `/security-review` も実行する
