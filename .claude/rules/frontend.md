---
paths:
  - "frontend/**/*"
---

@../../frontend/AGENTS.md

横断ルールは `../../CLAUDE.md` を参照。ここはNext.js固有の規約のみ。

## 開発の進め方

- **スキーマファースト**：叩くAPIは`doc/api-design.md`・`doc/api/openapi.yaml`に定義されているものだけを使う。ここに無いエンドポイントを先回りして実装しない
  - ⚠️**未整備（実装開始時に削除するTODO）**：`openapi-typescript`はまだpackage.jsonに無い。型生成の仕組みはまだ無く、手書きの型で代用せざるを得ない。最初にAPIを呼ぶ実装をするときに導入する
- 実コンポーネントを作るときは`.stories.tsx`も併せて作る（Storybook導入済み）
- デザインシステム（トークン化）は保留中。実コンポーネントが増えて繰り返しパターンが見えてから検討する

## データフェッチ

- **読み取り**（検索・一覧・詳細）はServer Componentで`fetch`する。絞り込み・ページングは`searchParams`でURLを変え、Server Componentが再取得する形にする
- **書き込み**（投稿・保存・連携解除・通報など）はServer Actionsを使う。ブラウザから直接`fetch`するコードは書かない
- Client Componentは「操作を受け取ってServer Actionを呼ぶ」「Server Componentから渡されたデータを表示する」役割に限定する
- Rails APIを呼ぶコードをどこに置くか（境界層を作るか、featureごとに置くか等）はまだ決めない。最初の実装で必要になった時点で、実際のコード量を見て判断する
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

- 1つのfeature内部の粒度（`components/`・`hooks/`・API呼び出しの置き場所等）はまだ決めない。実コードが増えてから判断する（横断ルールの「過剰なディレクトリ設計は禁止」に従う）
  - 検討中の候補：features/内の`components/`を`client/`・`server/`で分ける（理由：機能単位のコンポーネントは「ドメインデータを取得する（Server）」か「ユーザー操作を受ける（Client）」かで性質が分かれることが多いため）。ただし実物のコンポーネントが無い段階での先回りなので、最初のfeatureを書くときに決める
- Next.js自体が別DB（セッション・BFFキャッシュ等）を持つかどうかも未確定。backend側の認証方式が決まる前に、フロント側のセッション管理層を先に設計しない

## コンポーネント設計

- **Container/Presenter分割は使わない**。Hooks以前のパターンで、提唱者のDan Abramov自身もHooksの登場後に非推奨としている。ロジックの再利用はカスタムフック（`useXxx`）への抽出で十分。Next.js App RouterのServer Componentsがデータ取得の役割を担うため、Container相当の層は不要
- **compound components（`<Tabs><Tabs.Panel/></Tabs>`等）も既定にしない**。実際に複数パーツを柔軟に組み替えたい具体的なコンポーネントが出てきたとき、そのコンポーネント単位で判断する（上記デザインシステムと同じ理由）
- コンポーネントを分割するのは、実際に複数の見た目・複数のデータソースの組み合わせが必要になったときだけ

## テスト

コロケーション・拡張子（`.spec.tsx`）・カバレッジ方針・何を優先してテストするかは`.claude/rules/testing.md`を参照。

- テストランナーはVitestを導入予定（未確定）。導入が決まったらコマンドをここに追記する

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
```

## Storybook

```bash
pnpm storybook          # 開発用（http://localhost:6006）
pnpm build-storybook
```
