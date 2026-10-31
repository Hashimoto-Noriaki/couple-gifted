---
paths:
  - "frontend/**/*"
---

@../../frontend/AGENTS.md

横断ルールは `../../CLAUDE.md` を参照。ここはNext.js固有の規約のみ。

## 開発の進め方

- **スキーマファースト**：叩くAPIは`doc/api-design.md`・`doc/api/openapi.yaml`に定義されているものだけを使う。ここに無いエンドポイントを先回りして実装しない
  - APIの型は`openapi-typescript`で`doc/api/openapi.yaml`から生成した`shared/api-types.ts`を使う。手書きの型を置かない。`openapi.yaml`を更新したら`pnpm api-types:generate`で再生成する（生成物は手で編集しない）
- `.stories.tsx`は**対象のコンポーネントと同じ階層**に置く（例：`features/spots/components/SpotCard.tsx`の隣に`SpotCard.stories.tsx`）。Storyを作るのは部品（`components/`）だけで、画面（`SpotListPage`等）には作らない
- デザインシステム（トークン化）は保留中。実コンポーネントが増えて繰り返しパターンが見えてから検討する

## データフェッチ

- **読み取り**（検索・一覧・詳細）はServer Componentで`fetch`する。絞り込み・ページングは`searchParams`でURLを変え、Server Componentが再取得する形にする
- **書き込み**（投稿・保存・連携解除・通報など）はServer Actionsを使う。ブラウザから直接`fetch`するコードは書かない
- Client Componentは「操作を受け取ってServer Actionを呼ぶ」「Server Componentから渡されたデータを表示する」役割に限定する
- Rails APIを呼ぶコードは**featureごとに`features/<feature>/api.ts`へ置く**（#59で決定）。共通の境界層は作らない。ベースURL・エラー処理などの共通部分が複数featureで重複してきたら、そのとき`shared/`へ出す
- RailsのベースURLは環境変数`API_BASE_URL`（`frontend/.env.local`）。ローカルではRailsが3000番を使うため、Next.jsのdevは3001番で起動する
- **クライアント側のキャッシュ戦略は未定**。TanStack Queryの導入を予定しているが、用途（Server Actionsにかぶせるのか、特定機能でRails APIを直接叩くのか）は未決定。ここで断定しない。方針が決まったら追記する
- **環境変数**：`NEXT_PUBLIC_`プレフィックスを付けた値はブラウザに露出する。秘密情報（APIキー等）には付けない。上記の通りRails APIへの呼び出しはServer Component/Server Actionに限定しているため、本来`NEXT_PUBLIC_`が必要になる場面はほぼ無いはず。使いたくなったら、この境界の設計が破られていないか疑う

## ディレクトリ構成

**`app/`は薄く保つ**。`app/page.tsx`・`layout.tsx`はルーティング（ファイル配置・layout・loading／error境界）専用にし、`features/`のコンポーネントを呼ぶだけにする。ロジック・UIを`app/`直下に書かない。理由：

- backendの「Controllerは薄く。ロジックはModelに書く」（横断ルール）と同じ考え方。`app/`はルーティングの入口、実体は`features/`に置く
- App Routerの規約（ファイル名・layout・loading/error境界）はNext.jsのバージョンで変わりやすい。ロジックを`features/`側に置けば、規約変更の影響を`app/`だけに閉じ込められる
- `features/`に置けば、上記のテスト（コロケーションの`.spec.tsx`）やStorybookの対象にできる。`app/page.tsx`はNext.js側の特殊なファイルで、単体テストの対象にしにくい
- 同じfeatureを複数のルート（通常ページ・モーダルルート等）から呼び出したくなったときに再利用しやすい

```bash
frontend/
├── app/                  # ルーティングのみ
├── features/             # ドメイン単位（doc/api-design.mdの窓口一覧に対応）
│   ├── auth/             # 会員・認証
│   ├── couples/          # カップル連携・記念日
│   ├── spots/            # 検索・詳細・ランキング
│   ├── reviews/          # レビュー
│   ├── saves/            # 保存（共有・サプライズ）
│   └── diagnosis/        # 診断
└── shared/               # 複数featuresで使う純粋なUI・utils・型
```

- 1つのfeature内部は**役割で分ける**（`features/spots/`のファイルが増えた時点で決定）。新しいfeatureも、ファイルが少ないうちは直下に置き、増えてからこの形に分ける（横断ルールの「過剰なディレクトリ設計は禁止」に従う）

  ```bash
  features/spots/
  ├── SpotListPage.tsx   # 画面。app/から呼ぶ入口（Server Componentのレンダリングをテストする）
  ├── api.ts             # Rails APIの呼び出し
  ├── components/        # 画面の部品（Storybookで確認する側）
  └── lib/               # 表示用の純粋なロジック（Vitestで確認する側）
  ```

  - `client/`・`server/`で分ける案は採らない。最初のfeatureでClient Componentが1つ（`FilterSheet`）しかなく、ディレクトリにするほどの量が無いため
  - 画面ごと（`list/`・`detail/`）に分ける案も採らない。絞り込み条件・ヘッダー・評価表示を一覧と詳細の両方で使い、結局共通の置き場が要るため
  - `hooks/`はカスタムフックが実際に出てきたときに足す
- Next.js自体が別DB（セッション・BFFキャッシュ等）を持つかどうかも未確定。backend側の認証方式が決まる前に、フロント側のセッション管理層を先に設計しない

## コンポーネント設計

- **Container/Presenter分割は使わない**。Hooks以前のパターンで、提唱者のDan Abramov自身もHooksの登場後に非推奨としている。ロジックの再利用はカスタムフック（`useXxx`）への抽出で十分。Next.js App RouterのServer Componentsがデータ取得の役割を担うため、Container相当の層は不要
- **compound components（`<Tabs><Tabs.Panel/></Tabs>`等）も既定にしない**。実際に複数パーツを柔軟に組み替えたい具体的なコンポーネントが出てきたとき、そのコンポーネント単位で判断する（上記デザインシステムと同じ理由）
- コンポーネントを分割するのは、実際に複数の見た目・複数のデータソースの組み合わせが必要になったときだけ

## テスト

コロケーション・拡張子（`.spec.tsx`）・カバレッジ方針・何を優先してテストするかは`.claude/rules/testing.md`を参照。

- **TDDはしない**（backendのみ）。テストは実装の後に、hooks・整形ロジック・認証まわり等に絞って書く
- テストランナーはVitest。`pnpm test`（1回実行）・`pnpm test:watch`・`pnpm test:coverage`

## 用語（`doc/ubiquitous-language.md`準拠）

UIの文言・変数名・コンポーネント名で、決めた用語と違う言葉を使わない。
この節は`.coderabbit.yaml`のfrontend向けpath_instructionsと同内容。`doc/ubiquitous-language.md`かこちらを変更したら、もう一方と`.coderabbit.yaml`も直す（3箇所を同期させる）。

| 使う言葉 | 意味 | 使わない言葉 |
| --- | --- | --- |
| 共有 | 保存リストがパートナーに見える状態 | ー |
| サプライズ | 保存リストが本人にしか見えない状態 | 非公開、プライベート |
| 連携 | パートナーとつながっている状態 | 共有（この意味では） |
| 連携解除 | 連携を終了させること（不可逆） | カップル解除、解除（単体） |
| 絞り込みを外す | 検索条件をクリアすること | 解除 |
| カップルレビュー / ソロレビュー | カップルに紐づく／個人に紐づくレビュー | 共有レビュー |
| 子連れ訪問 | そのとき子どもを連れて行ったか（レビューの属性） | 子どもの有無（この意味では） |

予算帯を表示するUIでは「ふたり合計・税込」であることを画面上に必ず明示する。

## Lint・フォーマット

```bash
pnpm lint        # ESLint
pnpm check        # Biome チェック
pnpm check:fix     # 自動修正
pnpm format        # フォーマットのみ
pnpm type-check    # tsc --noEmit（型チェックのみ、出力しない）
```

CIでは`frontend_check` job（`.github/workflows/ci.yml`）で`pnpm check`・`pnpm type-check`・`pnpm test`を実行する。

## Storybook

```bash
pnpm storybook          # 開発用（http://localhost:6006）
pnpm build-storybook
```
