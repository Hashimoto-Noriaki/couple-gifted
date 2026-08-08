---
name: pr-description
description: PRの説明文をテンプレートに沿って生成する
---

1. ベースブランチは `master` を使う
2. `git diff $(git merge-base HEAD <ベースブランチ>)..HEAD` で差分を確認する
3. 下記の「タイトル」「本文」のフォーマットに沿って PR 説明文を生成し、ユーザーに提示する（`.github/pull_request_template.md`は存在しないため使わない）
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
- API エンドポイント追加・変更 → `doc/api-design.md`（将来的には`openapi.yaml`）の更新項目を残す
- バックエンド変更 → `bundle exec rubocop -a` 実行項目を残す
- フロントエンド変更 → テストコマンドは未確定（Vitest未導入、`.claude/rules/testing.md`参照）。導入後に実行項目を追記する
- それ以外の項目は該当する場合のみ残す
