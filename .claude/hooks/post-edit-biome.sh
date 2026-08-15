#!/bin/bash
# フロントエンドファイル編集後にBiomeを自動実行する

# プロジェクトルートを確定（このスクリプトは .claude/hooks/ にある）
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

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
if [[ "$FILE" = /* ]]; then
    # 絶対パスの場合、プロジェクトルート/frontend/ を除去
    RELATIVE="${FILE#$PROJECT_ROOT/frontend/}"
else
    # 相対パスの場合、frontend/ を除去
    RELATIVE="${FILE#frontend/}"
fi

cd frontend && pnpm exec biome check --write "$RELATIVE" 2>&1
