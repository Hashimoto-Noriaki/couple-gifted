---
name: pr-description
description: PRの説明文をテンプレートに沿って生成する
---

値をコマンド文字列に直接埋め込まない。`"`・`` ` ``・`$()`等が含まれるとコマンドが壊れる、または意図しないシェル展開・コマンド置換が発生するため、必ず変数に格納してから`"$変数名"`の形で参照する。本文はさらに一時ファイルに書き出し、`--body-file`で渡す。

1. ベースブランチを変数に入れる: `base_branch="master"`
2. 差分を確認する: `git diff "$(git merge-base HEAD "$base_branch")"..HEAD`
3. 下記の「タイトル」「本文」のフォーマットに沿って PR 説明文を生成し、ユーザーに提示する
4. ユーザーの承認を得たら、以下の手順でPRを作成する
   1. 本文をWriteツール等で一時ファイルに書き出す（例: `/tmp/pr-body.md`）
   2. 現在のブランチ名とタイトルを変数に入れる:
      ```shell
      current_branch=$(git branch --show-current)
      title="<生成したタイトル>"
      ```
   3. push（未 push の場合のみ）:
      ```shell
      git push -u origin "$current_branch"
      ```
   4. PR作成:
      ```shell
      gh pr create --title "$title" --base "$base_branch" --body-file /tmp/pr-body.md
      ```

## タイトル

コミットプレフィックス規約に従う: `feat` / `fix` / `chore` / `refactor` / `docs` / `test`

## 本文

テンプレートの各セクションを埋める:

- **概要**: 変更の目的を 1〜2 文で
- **変更内容**: 変更したファイル・機能を箇条書き
- **テスト計画**: backend / frontend の変更に応じてチェックボックスを残す（不要なものは削除）
- **チェックリスト**: 以下の基準で必要な項目だけ残す
  - API エンドポイント追加・変更 → `doc/api-design.md`（将来的には`openapi.yaml`）の更新項目を残す
  - バックエンド変更 → `bundle exec rubocop -a` 実行項目を残す
  - フロントエンド変更 → テストコマンドは未確定（Vitest未導入、`.claude/rules/testing.md`参照）。導入後に実行項目を追記する
  - それ以外の項目は該当する場合のみ残す
