# フロントエンド開発規約

## 技術スタック

- Next.js 16.2 / TypeScript
- pnpm（npm / yarn 禁止）
- Biome（リント）
- Vitest + jsdom + @testing-library/react（テスト）

## コマンド

- `pnpm exec biome check .`（リント）
- `pnpm test`（ウォッチモード）
- `pnpm test run`（CI 用）

## テスト

- テストファイルは `*.test.tsx` として対象コンポーネントの隣に配置する
