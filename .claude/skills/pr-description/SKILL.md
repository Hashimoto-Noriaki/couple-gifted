---
description: PRの説明文をテンプレートに沿って生成する
---

1.ベースブランチを特定する（通常はリポジトリのデフォルトブランチ）
2. `git diff $(git merge-base HEAD <ベースブランチ>)..HEAD` で差分を確認する
3. `.github/pull_request_template.md` のフォーマットに沿って PR 説明文を生成する

## タイトル

コミットプレフィックス規約に従う: `feat` / `fix` / `chore` / `refactor` / `docs` / `test`

## 本文

テンプレートの各セクションを埋める:

- **概要**: 変更の目的を 1〜2 文で
- **変更内容**: 変更したファイル・機能を箇条書き
- **テスト計画**: backend / frontend の変更に応じてチェックボックスを残す（不要なものは削除）
**チェックリスト**: 以下の基準で必要な項目だけ残す
- API エンドポイント追加・変更 → `openapi.yaml` と `docs/api.md` の更新項目を残す
- バックエンド変更 → `bundle exec rubocop -A` 実行項目を残す
- フロントエンド変更 → `pnpm test run` 実行項目を残す
- それ以外の項目は該当する場合のみ残す
