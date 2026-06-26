---
description: PRの説明文をテンプレートに沿って生成する
---

1. ベースブランチを特定する（`develop` があれば優先、なければ `main` / `master`）
2. `git diff $(git merge-base HEAD <ベースブランチ>)..HEAD` で差分を確認する
3. `.github/pull_request_template.md` のフォーマットに沿って PR 説明文を生成し、ユーザーに提示する
4. ユーザーの承認を得たら、以下を順に実行してPRを作成する
   - リモートブランチへの push（未 push の場合のみ）: `git push -u origin <現在のブランチ名>`
   - PR 作成:
     ```
     gh pr create --title "<タイトル>" --base <ベースブランチ> --body "$(cat <<'EOF'
     <本文>
     EOF
     )"
     ```

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
