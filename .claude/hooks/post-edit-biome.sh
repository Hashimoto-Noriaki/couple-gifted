#!/bin/bash
# フロントエンドファイル編集後にBiomeを自動実行する

FILE="$1"

# TypeScript/JavaScript以外はスキップ
if [[ "$FILE" != *.ts && "$FILE" != *.tsx && "$FILE" != *.js && "$FILE" != *.jsx ]]; then
    exit 0
fi

# frontend/ 配下でなければスキップ
if [[ "$FILE" != *frontend/* ]]; then
    exit 0
fi

# 絶対パス・相対パスどちらで渡ってきても、frontend/ 以降を取り出す
RELATIVE="${FILE#*frontend/}"

cd frontend && pnpm exec biome check --write "$RELATIVE" 2>&1
