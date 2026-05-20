#!/bin/bash
# Railsファイル編集後にRubocopを自動実行する

FILE="$1"

# Ruby/Railsファイル以外はスキップ
if [[ "$FILE" != *.rb ]]; then
  exit 0
fi

docker compose exec -T api bundle exec rubocop -A "$FILE" 2>&1
