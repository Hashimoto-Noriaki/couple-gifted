#!/bin/bash
# Railsファイル編集後にRubocopを自動実行する

FILE="$1"

# Ruby/Railsファイル以外はスキップ
if [[ "$FILE" != *.rb ]]; then
    exit 0
fi

# backend/ 配下でなければスキップ（コンテナは backend/ を /rails にマウントしている）
if [[ "$FILE" != *backend/* ]]; then
    exit 0
fi

# 絶対パス・相対パスどちらで渡ってきても、backend/ 以降（コンテナ内 /rails からの相対パス）を取り出す
RELATIVE="${FILE#*backend/}"

docker compose exec -T api bundle exec rubocop -A "$RELATIVE" 2>&1
