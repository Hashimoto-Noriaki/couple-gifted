---
name: ci-check
description: CIと同じLint・セキュリティチェック・テストを手元で実行して結果を報告する。実装後やPR作成前に使う
argument-hint: "[backend|frontend]"
allowed-tools: Bash(docker compose ps*), Bash(docker compose exec api bin/brakeman --no-pager), Bash(docker compose exec api bin/bundler-audit), Bash(docker compose exec api bin/rubocop), Bash(docker compose exec api bundle exec rspec), Bash(pnpm --dir frontend check), Bash(pnpm --dir frontend type-check), Bash(pnpm --dir frontend test)
---

`.github/workflows/ci.yml` の job を手元で再現し、結果を報告する。

引数: `$ARGUMENTS`

## 範囲

| 引数 | 実行範囲 |
| --- | --- |
| なし | backend + frontend |
| `backend` | backend のみ |
| `frontend` | frontend のみ |

それ以外の引数なら何も実行せず、上の使い方を伝える。

## 実行するコマンド

リポジトリルートで、上から順に実行する。1つ失敗しても残りは止めずに最後まで実行する（失敗をまとめて把握するため）。

### backend

```bash
docker compose exec api bin/brakeman --no-pager
docker compose exec api bin/bundler-audit
docker compose exec api bin/rubocop
docker compose exec api bundle exec rspec
```

先に `docker compose ps` で `api` が起動しているか確認する。起動していなければ backend は実行せず、「未実行」として起動コマンド（`HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose up -d --build`）を案内する。コンテナを勝手に起動しない。

### frontend

```bash
pnpm --dir frontend check
pnpm --dir frontend type-check
pnpm --dir frontend test
```

## 失敗したとき

**報告のみ。自動修正しない。** `rubocop -a`・`pnpm check:fix`・`bundle update` などの修正コマンドは実行せず、コードも編集しない（unsafe な修正は人が確認するルールのため。`.claude/rules/backend.md` 参照）。

次の2つはコードが原因ではないことがあるので、報告に添える。

- `bin/bundler-audit` の失敗：脆弱性DBの更新で、変更と無関係に落ちることがある
- `bin/brakeman` の exit code 5（`Brakeman X is not the latest version Y`）：`--ensure-latest` によるもの。対処は `.claude/rules/backend.md` の「つまずきやすい点」参照

## 報告フォーマット

実行結果を表にまとめ、失敗があれば下にエラーの要点（ファイル・行番号・メッセージ）を列挙する。実行していないものは「未実行」と書き、成功扱いにしない。

```text
| 範囲 | チェック | 結果 |
| --- | --- | --- |
| backend | brakeman | OK |
| backend | bundler-audit | OK |
| backend | rubocop | NG（2件） |
| backend | rspec | OK（85 examples） |
| frontend | biome | OK |
| frontend | type-check | OK |
| frontend | vitest | OK（29 tests） |

[rubocop] app/models/user.rb:12 Style/StringLiterals ...
```
