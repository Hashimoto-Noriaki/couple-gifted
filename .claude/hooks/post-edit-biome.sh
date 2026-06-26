#!/bin/bash
# フロントエンドファイル編集後にBiomeを自動実行する

FILE="$1"

# TypeScript/JavaScript以外はスキップ
if [[ "$FILE" != *.ts && "$FILE" != *.tsx && "$FILE" != *.js && "$FILE" != *.jsx ]]; then
  exit 0
fi

cd frontend && pnpm exec biome check --write "$FILE" 2>&1
