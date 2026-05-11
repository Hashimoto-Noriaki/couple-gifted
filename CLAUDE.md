# CLAUDE.md

## サービス概要

CoupleGifted（カップルギフテッド）
カップル・夫婦向けのライフプラットフォーム。
「パートナーが喜ぶ」を軸に、デートスポット・プレゼント・コスメなど
交際中から結婚後まで長く使えるサービス。

## ドキュメント

- サービス概要:   docs/overview.md
- 機能一覧:       docs/features.md
- データモデル:   docs/model.md
- API設計:        docs/api.md
- 開発手順:       docs/development.md
- チーム方針:     docs/team.md

## MVP（現在開発中）

デートスポット検索に特化。
シーン別・エリア検索、Google Places API連携、口コミ・いいね、ユーザー認証。

## 将来の展開

- Phase 2: コスメ・プレゼント検索（楽天API連携）
- Phase 3: AI診断・記念日リマインド・広告機能

## リポジトリ構成

- backend/  : Ruby on Rails 8.0（API mode）← 現在開発中
- frontend/ : Next.js（未着手）

## 開発の大原則

- TDDで開発する。Specを先に書いてから実装する
- Controllerは薄く。ロジックはService・Modelに書く
- テストなしで実装を進めない
- N+1クエリを放置しない
- 必ずRuboCopをPR前に使う

## Gitルール

- ブランチ: feature/ fix/ hotfix/ refactor/ docs/ chore/
- コミット: feat: / fix: / hotfix: / test: / refactor: / docs: / chore:
- PRを出したらCodeRabbitのレビューを確認してからマージ

## よく使うコマンド（Docker）

- docker compose up -d             # コンテナ起動
- docker compose down              # コンテナ停止
- docker compose logs -f api       # ログ確認

## よく使うコマンド（フロントエンド）

- cd frontend && pnpm lint              # Biome Lint チェック
- cd frontend && pnpm format            # Biome フォーマット
- cd frontend && pnpm biome check .     # Lint + Format まとめてチェック
- cd frontend && pnpm biome check --write .  # 自動修正

## 使用ツール

- Claude Code    : AI駆動開発（ターミナル・VSCode両方）
- CodeRabbit     : PR自動レビュー
- GitHub Actions : CI（RSpec自動実行）

## 未定事項（決まり次第追記）

- frontend/ のディレクトリ構成
- デプロイ先（未定）
