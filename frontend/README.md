[Next.js](https://nextjs.org) 製のフロントエンド。

## Getting Started

```bash
pnpm dev
```

[http://localhost:3000](http://localhost:3000) をブラウザで開くと確認できます。

## Lint & Format

Next.js固有のルールチェックに [ESLint](https://eslint.org)（`eslint-config-next`）、一般的なlint・フォーマットに [Biome](https://biomejs.dev) を使用しています。

```bash
# ESLint（Next.js固有のルールチェック）
pnpm lint

# Biome（lint + フォーマットチェック）
pnpm check

# Biome（lint + フォーマットを自動修正）
pnpm check:fix

# Biome（フォーマットのみ自動修正）
pnpm format
```

## Storybook

UIコンポーネントを個別に開発・確認するために [Storybook](https://storybook.js.org) を使用しています。Storyファイルは `app/` 配下のコンポーネントと同じ場所に置きます（`*.stories.tsx`）。

```bash
# Storybookを起動（http://localhost:6006）
pnpm storybook

# Storybookの静的サイトをビルド
pnpm build-storybook
```
