# フロントエンド

## Getting Started

依存パッケージをインストールする:

```bash
pnpm install
```

開発サーバーを起動する:

```bash
pnpm dev
```

## テスト（Vitest）

```bash
# ウォッチモード（開発中）
pnpm test

# 一回実行して終了（CI用）
pnpm test run

# UIモード
pnpm test:ui
```

テストファイルは `*.test.tsx` として対象コンポーネントの隣に配置する。
