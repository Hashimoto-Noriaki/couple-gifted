---
name: ci-check
description: CIと同じLint・セキュリティチェック・テストを手元で実行して結果を報告する。実装後やPR作成前に使う
argument-hint: "[backend|frontend]"
allowed-tools: Bash(docker compose ps*), Bash(docker inspect*), Bash(pwd -P), Bash(node --version), Bash(docker compose exec api bin/brakeman --no-pager), Bash(docker compose exec api bin/bundler-audit), Bash(docker compose exec api bin/rubocop), Bash(docker compose exec api bundle exec rspec), Bash(pnpm --dir frontend install --frozen-lockfile), Bash(pnpm --dir frontend check), Bash(pnpm --dir frontend type-check), Bash(pnpm --dir frontend test)
---

`.github/workflows/ci.yml`（全 PR と `master` への push で実行）の job を手元で再現し、結果を報告する。追加チェックの `bundler-audit` は CI 本体と分けて報告する。

引数: `$ARGUMENTS`

## 範囲

| 引数 | 実行範囲 |
| --- | --- |
| なし | backend + frontend |
| `backend` | backend のみ |
| `frontend` | frontend のみ |

それ以外の引数なら何も実行せず、上の使い方を伝える。

## 実行するコマンド

リポジトリルートで、上から順に実行する。前提条件を確認した後は、チェックが1つ失敗しても残りを最後まで実行する（失敗をまとめて把握するため）。

### backend

```bash
docker compose exec api bin/brakeman --no-pager
docker compose exec api bin/bundler-audit
docker compose exec api bin/rubocop
docker compose exec api bundle exec rspec
```

先に `docker compose ps` で `api` が起動しているか確認する。起動していなければ backend は実行せず、「未実行」として起動コマンド（`HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose up -d --build`）を案内する。コンテナを勝手に起動しない。

起動中の場合、`docker compose ps -q api` でコンテナ ID を取得し、各 ID に対して `docker inspect --format '{{range .Mounts}}{{println .Type .Source .Destination}}{{end}}' <ID>` でマウントを確認する。`pwd -P` で得た現在の worktree のルートと照らし、`/rails` と `/doc` の bind mount 元がそれぞれその worktree の `backend` と `doc` であることを確認する。ID が取得できない場合や、マウント元が一致しない・確認できない場合は backend を実行せず、理由とともに「未実行」と報告する。

### frontend

CI は `actions/setup-node` の `lts/*` を使う。対象の CI 実行の Node.js セットアップログで解決されたバージョンを確認し、同じバージョンを使う。`node --version` でローカルのバージョンを確認し、報告に両方のバージョンを記載する。CI のバージョンが不明または一致しない場合、frontend の結果はローカル参考結果とし、CI 相当とは報告しない。

```bash
pnpm --dir frontend install --frozen-lockfile
pnpm --dir frontend check
pnpm --dir frontend type-check
pnpm --dir frontend test
```

インストールに失敗した場合は後続の frontend チェックを実行せず、失敗の理由とともに frontend を「未実行」と報告する。

## 失敗したとき

**報告のみ。自動修正しない。** `rubocop -a`・`pnpm check:fix`・`bundle update` などの修正コマンドは実行せず、コードも編集しない（unsafe な修正は人が確認するルールのため。`.claude/rules/backend.md` 参照）。

次の2つはコードが原因ではないことがあるので、報告に添える。

- `bin/bundler-audit` の失敗：脆弱性DBの更新で、変更と無関係に落ちることがある。これは `ci.yml` のチェックではなく、`.github/workflows/bundler-audit.yml` で週次・手動実行、および `backend/Gemfile` または `backend/Gemfile.lock` が変更された PR のみに実行される。これらの変更がない PR では実行されないため、ローカルでの失敗は CI 本体の失敗を意味しない。
- `bin/brakeman` の exit code 5（`Brakeman X is not the latest version Y`）：`--ensure-latest` によるもの。対処は `.claude/rules/backend.md` の「つまずきやすい点」参照

## 報告フォーマット

CI 本体と追加チェックを分けて実行結果を表にまとめ、失敗があれば下にエラーの要点（ファイル・行番号・メッセージ）を列挙する。frontend が CI と異なる Node.js で実行された場合や CI のバージョンが不明な場合は、結果をローカル参考結果と明記する。実行していないものは「未実行」と書き、成功扱いにしない。

```text
CI 本体
| 範囲 | チェック | 結果 |
| --- | --- | --- |
| backend | brakeman | OK |
| backend | rubocop | NG（2件） |
| backend | rspec | OK（85 examples） |
| frontend | biome | OK |
| frontend | type-check | OK |
| frontend | vitest | OK（29 tests） |

追加チェック
| 範囲 | チェック | 結果 |
| --- | --- | --- |
| backend | bundler-audit | OK |

[rubocop] app/models/user.rb:12 Style/StringLiterals ...
```
