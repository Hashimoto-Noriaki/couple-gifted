#!/bin/bash
# Railsファイル編集後にRubocopを自動実行する

# プロジェクトルートを確定（このスクリプトは .claude/hooks/ にある）
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

FILE="$1"

# Ruby/Railsファイル以外はスキップ
BASENAME="$(basename "$FILE")"
case "$BASENAME" in
    *.rb|Gemfile|Rakefile|config.ru|*.rake|*.gemspec)
        # RuboCopで処理するファイル
        ;;
    *)
        exit 0
        ;;
esac

# backend/ 配下でなければスキップ（コンテナは backend/ を /rails にマウントしている）
if [[ "$FILE" != *backend/* ]]; then
    exit 0
fi

# 絶対パス・相対パスどちらで渡ってきても、backend/ 以降（コンテナ内 /rails からの相対パス）を取り出す
if [[ "$FILE" = /* ]]; then
    # 絶対パスの場合、プロジェクトルート/backend/ を除去
    RELATIVE="${FILE#$PROJECT_ROOT/backend/}"
else
    # 相対パスの場合、backend/ を除去
    RELATIVE="${FILE#backend/}"
fi

docker compose exec -T api bundle exec rubocop -A "$RELATIVE" 2>&1
