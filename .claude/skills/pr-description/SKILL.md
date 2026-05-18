---
description: PRの説明文をテンプレートに沿って生成する
---

`git diff $(git merge-base HEAD origin/develop)..HEAD` で差分を確認し、`.github/pull_request_template.md` のフォーマットに沿って PR 説明文を生成する。

## タイトル

コミットプレフィックス規約に従う: `feat` / `fix` / `chore` / `refactor` / `docs` / `test`

## 本文

テンプレートの各セクションを埋める:

- **概要**: 変更の目的を 1〜2 文で
- **変更内容**: 変更したファイル・機能を箇条書き
- **テスト計画**: backend / frontend の変更に応じてチェックボックスを残す（不要なものは削除）
- **チェックリスト**: 変更内容に応じて必要な項目だけ残す（API変更がなければ openapi.yaml の項目は削除するなど）
