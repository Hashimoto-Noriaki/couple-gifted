# [Next.js](https://nextjs.org) 製のフロントエンド

## Getting Started

Rails API（docker compose、3000番）を先に起動し、`frontend/.env.local` にAPIのベースURLを書いておく。
Rails APIはServer Componentからだけ呼ぶため、`NEXT_PUBLIC_`は付けない。

```bash
# frontend/.env.local
API_BASE_URL=http://localhost:3000/api/v1
```

```bash
pnpm dev
```

Railsと衝突しないよう3001番で起動する。[http://localhost:3001](http://localhost:3001) をブラウザで開くと確認できます。

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

UIコンポーネントを個別に開発・確認するために [Storybook](https://storybook.js.org) を使用しています。Storyファイルは `app/`・`features/` 配下のコンポーネントと同じ場所に置きます（`*.stories.tsx`）。

```bash
# Storybookを起動（http://localhost:6006）
pnpm storybook

# Storybookの静的サイトをビルド
pnpm build-storybook
```
