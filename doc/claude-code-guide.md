# Claude Codeの設定ガイド（CLAUDE.md・.claude/）

- **最終更新**：2026-08-19
- **対象読者**：Claude Code（AIコーディングツール）を初めて触る人・駆け出しエンジニア
- **本書の範囲**：`CLAUDE.md`・`.claude/`配下・`frontend/AGENTS.md`が「何のためにあり、何を書いてあるか」を説明する。中身のルールそのもの（TDDの詳細、ドメインルールの中身など）は各ファイルと`doc/`の他ドキュメントが正本。ここはあくまで「地図」

---

## そもそもこれは何？

このリポジトリをClaude Code（AIがコードを書く手伝いをするツール）で開発すると、
AIは`CLAUDE.md`と`.claude/`配下のファイルを**毎回自動で読み込んで**から作業する。

人間の新入社員に例えると：

- `CLAUDE.md` … 「このプロジェクトのオンボーディング資料」。全体の方針・置き場所を教える
- `.claude/rules/*.md` … 「配属先チームの詳細ルール集」。backend担当・frontend担当それぞれの細かい決め事
- `.claude/hooks/` … 「保存したら自動でLintが走る」ような自動化スクリプト
- `.claude/skills/` … 「よく使う定型作業のテンプレート」（Issue作成・コミットメッセージ作成など）
- `.claude/settings.json` … 「これはやっていい／これは絶対やってはいけない」という権限設定
- `frontend/AGENTS.md` … 「frontendディレクトリに入ったら真っ先に読むべき注意書き」

これらはAI向けに書かれているが、**人間の開発者が読んでも「このプロジェクトのルール一覧」として使える**。
むしろ「AIに何を守らせたいか」を書いたものなので、プロジェクトの決め事がかなり濃縮されている。

> 迷ったらまず`CLAUDE.md`。`CLAUDE.md`に書いていない「このプロジェクトの方針」を勝手に決めつけない
> （これは`CLAUDE.md`自身に書いてあるルール）。

---

## 全体マップ

```text
couple-gifted/
├── CLAUDE.md                        # 横断ルール（backend・frontend共通の方針）
├── frontend/AGENTS.md                # frontendディレクトリ専用の注意書き
├── doc/                              # ドキュメント（要件・ドメイン・API設計など。正本はこちら）
│   └── claude-code-guide.md          # ← このファイル
├── .coderabbit.yaml                  # PRレビューAI（CodeRabbit）の設定。ドメインルールを埋め込み済み
└── .claude/
    ├── settings.json                 # 権限設定（許可コマンド・禁止コマンド）＋ hooks の登録
    ├── rules/
    │   ├── backend.md                 # Rails固有ルール（CLAUDE.mdの差分のみ）
    │   ├── frontend.md                # Next.js固有ルール（同上）
    │   ├── testing.md                 # テスト方針（TDD・カバレッジ・対象範囲）
    │   └── git.md                     # ブランチ・コミット・PRの進め方
    ├── hooks/
    │   ├── post-edit-rubocop.sh       # Rubyファイル編集後にRuboCopを自動実行
    │   └── post-edit-biome.sh         # TS/JSファイル編集後にBiomeを自動実行
    └── skills/
        ├── check-n1/Skill.md          # N+1クエリ検出（/check-n1）
        ├── create-issue/Skill.md      # GitHub issue作成（/create-issue）
        ├── pr-description/Skill.md    # PR説明文生成（/pr-description）
        └── smart-commit/Skill.md      # コミットメッセージ生成（/smart-commit）
```

読む順番のおすすめ：`CLAUDE.md` → 自分の担当（`.claude/rules/backend.md`または`frontend.md`）→
`.claude/rules/testing.md`・`git.md`。hooks・skills・settings.jsonは「そういう自動化があるんだ」と
知っておく程度で最初は十分。

---

## `CLAUDE.md`（横断ルール）

リポジトリ直下にある。**backend・frontend共通の方針だけ**を書く場所と決まっている
（スタック固有の詳細は書かない。混ぜると、Railsの話とNext.jsの話が同じファイルに散らばって読みにくくなるため）。

主な内容：

| セクション | 何が書いてあるか |
| --- | --- |
| リポジトリ構成 | `backend`・`frontend`・`doc`が何か |
| ドキュメント | `doc/`配下の各ファイルの役割一覧。仕様に迷ったらここを見に行く |
| 開発の進め方 | TDD・スキーマファースト・「Controllerは薄く」・N+1放置禁止 |
| Git・ブランチ・PR | 詳細は`.claude/rules/git.md`へのポインタ |
| ディレクトリ構成 | 「最初は単一ファイルで始める」「過剰な先回り設計は禁止」 |
| リポジトリの位置づけ | このリポジトリがPOC・MVP検証＋教育の場であること |
| ローカル開発（Docker） | backend起動コマンド |

**「スキーマファースト」**は特に重要なキーワード。エンドポイントを追加・変更するときは、
先に`doc/api-design.md`を更新してから実装する。逆順（先にコード、後でドキュメント）はNG。

---

## `.claude/rules/`（スタック固有のルール）

`CLAUDE.md`に書かれていない、Rails固有・Next.js固有の細かいルール。
それぞれのファイル冒頭に`paths:`という指定があり、対応するディレクトリを編集するときだけ
Claude Codeに自動で読み込まれる仕組みになっている（`backend.md`は`backend/**/*`、`frontend.md`は`frontend/**/*`）。

### `backend.md`（Rails）

- バージョンは`Gemfile`・`.ruby-version`が正（ここには書かない＝ドリフト防止）
- DBはSQLite3。認証方式・シリアライズ方式は未決定であることが明記されている
  （＝「まだ決めていないことを、決めたかのように書かない」というスタンス）
- **ドメインルール**：`doc/domain-model.md`の「技術の都合で歪めてはいけない判断」を転記。
  例えば「招待コードのエラーは理由を問わず同じメッセージを返す」「サプライズ保存は存在自体が
  パートナーに伝わってはいけない」など。ここは`.coderabbit.yaml`とも内容を合わせてある
  （後述の「3箇所同期」を参照）
- API規約：`/api/v1/`始まり、エラーはRFC 9457（Problem Details）形式に統一
- 管理画面はAPIを経由せず、Railsの通常のController/View（ERB）で作る、という決定も明記

### `frontend.md`（Next.js）

- 冒頭で`frontend/AGENTS.md`を読み込む指定になっている（後述）
- データフェッチ方針：**読み取りはServer Component、書き込みはServer Actions**。
  ブラウザから直接`fetch`するコードは書かない
- ディレクトリ構成：`app/`はルーティング専用で薄く保ち、実体は`features/`に置く
- コンポーネント設計：Container/Presenter分割やcompound componentsを既定にしない、といった
  「あえてやらないこと」の宣言も含む
- 用語集（`doc/ubiquitous-language.md`準拠）：「共有」「サプライズ」「連携」などの言葉の使い分けを
  一覧表で掲載

### `testing.md`（テスト方針）

- TDD：Specを先に書いてから実装する
- カバレッジ目標は**C1（分岐カバレッジ）**。「if分岐そのものが仕様」というこのプロジェクトの
  特性上、C0（行カバレッジ）より相性が良いという理由も書かれている
- backend/frontendそれぞれの「何を優先してテストするか」の考え方
- E2Eはfrontendでは認証（サインアップ・ログイン・ログアウト）のみに絞る、という決定

### `git.md`（ブランチ・コミット・PR）

- ブランチ名は`<prefix>/<kebab-case>`（例：`feat/review-post`）
- コミットプレフィックス：`feat` / `test` / `fix` / `chore` / `refactor` / `docs`
- PRは**CodeRabbitのレビューを確認してからマージ**。マージ前に`/code-review`
  （必要なら`/security-review`）を実行する
- **「3箇所同期」のルール**が明記されている（次のセクションで説明）

---

## ドキュメントの「3箇所同期」ルール

このリポジトリで一番間違えやすいポイント。ドメインルールと用語は、**正本1つ＋埋め込み先2つ**の
計3箇所に同じ内容が書かれている。

| 正本 | 埋め込み先1 | 埋め込み先2 |
| --- | --- | --- |
| `doc/domain-model.md` | `.coderabbit.yaml`のpath_instructions | `.claude/rules/backend.md` |
| `doc/ubiquitous-language.md` | `.coderabbit.yaml`のpath_instructions | `.claude/rules/frontend.md` |

なぜ3箇所も要るのか：

- `doc/`は「仕様書」。人間もAIも、迷ったらまずここを見る
- `.claude/rules/*.md`は「実装中にClaude Codeへ直接ルールを埋め込む」場所。
  ファイルパスに応じて自動で読み込まれるので、都度`doc/`を探しに行かなくてもルールが目に入る
- `.coderabbit.yaml`は「PRレビュー時にCodeRabbit（別のAI）へ直接ルールを埋め込む」場所。
  実装側（Claude Code）とレビュー側（CodeRabbit）で見ているルールがズレないようにする

**したがって：ドメインルールや用語を変更したら、この3ファイルを同時に直す。**
1箇所だけ直すと、実装とレビューの基準が食い違う（AIが正しく実装してもレビューAIに指摘される、
またはその逆が起こる）。

---

## `.claude/hooks/`（保存すると自動で走るスクリプト）

Claude CodeがファイルをEdit・Writeした**直後に自動実行**されるスクリプト
（`.claude/settings.json`の`PostToolUse`フックで登録されている）。人間が手でLintを打たなくても、
AIが編集したファイルは自動整形される。

| フック | 対象 | やること |
| --- | --- | --- |
| `post-edit-rubocop.sh` | `backend/`配下の`.rb`・`Gemfile`等 | `docker compose exec -T api bundle exec rubocop -A`を自動実行（安全な自動修正） |
| `post-edit-biome.sh` | `frontend/`配下の`.ts`/`.tsx`/`.js`/`.jsx` | `pnpm exec biome check --write`を自動実行 |

対象外のファイル（例：Rubyファイル編集時のBiomeフック）は何もせず即終了する
（スクリプト冒頭の拡張子チェック・ディレクトリチェックで弾いている）。

> 自動修正はあくまで「安全な（safeな）修正」のみ。unsafeな修正は人間が個別に確認して適用する方針
> （`.claude/rules/backend.md`のLint節を参照）。

---

## `.claude/settings.json`（権限設定）

Claude Codeが「確認なしで実行してよいコマンド（allow）」と「絶対に実行してはいけないコマンド（deny）」
を定義している。加えて、上記hooksの登録もここに書かれている。

### allow（確認なしで実行できる）

主にDockerコンテナ内でのRSpec・RuboCop・Rails・Rake実行、pnpmコマンド、`git status`/`diff`/`log`/`branch`/`commit`など、
日常的に頻発する読み取り系・開発系コマンド。

### deny（絶対に実行しない）

大きく3種類：

1. **破壊的なGit操作**：`git push -f`、`git reset --hard`、`git clean -f`、`git commit --amend`など
2. **DBを吹き飛ばすコマンド**：`db:drop`・`db:reset`・`db:migrate:reset`、`docker compose down -v`（ボリューム削除）など
3. **秘密情報の読み取り**：`.env`系ファイル、`config/master.key`、`config/credentials.yml.enc`、`*.pem`、SSH秘密鍵など

これはAIの暴走・誤操作を防ぐための安全装置。人間が手動で同じコマンドを打つのは別に構わないが、
**「AIに勝手にやらせたくない操作」がここに列挙されている**と考えるとよい。

---

## `.claude/skills/`（よく使う定型作業のテンプレート）

`/コマンド名`の形でClaude Codeから呼び出せる、定型作業の手順書。人間で言う「作業マニュアル」に近い。

| コマンド | 何をするか |
| --- | --- |
| `/check-n1` | Controller・Service・Modelを読んでN+1クエリの疑いがある箇所を検出し、`includes`等の修正案を提示する |
| `/create-issue` | ユーザーとの会話をもとに、テンプレートに沿ったGitHub issueを作成する（バグ報告／機能要望・タスク） |
| `/pr-description` | 差分を見て、PRのタイトル・本文（概要・変更内容・テスト計画・チェックリスト）を生成する |
| `/smart-commit` | ステージ済みの差分を見て、プレフィックス規則（`feat`/`fix`/`test`/`refactor`/`docs`/`chore`）に沿ったコミットメッセージを生成する |

いずれも「毎回ゼロから考えると表記ゆれが起きる作業」をテンプレート化したもの。
中身を直接読めば、そのまま「このプロジェクトでのIssue・PR・コミットメッセージの書き方ガイド」として使える。

---

## `frontend/AGENTS.md`（frontend専用の注意書き）

`frontend/`ディレクトリ直下にある、1ファイルだけの短い注意書き。`.claude/rules/frontend.md`の
冒頭で読み込まれる指定になっている。

内容は「このNext.jsのバージョンは学習データにある一般的なNext.jsと違う可能性があるので、
コードを書く前に`node_modules/next/dist/docs/`のガイドを確認せよ」という趣旨。
Next.jsはバージョンごとの変化が大きいフレームワークなので、AIが古い書き方（学習データの知識）で
実装してしまう事故を防ぐための注意書き。

---

## 実際の開発フローに当てはめると

例えば「レビュー投稿APIを追加する」タスクの場合、これらのファイルは次のように働く。

1. `CLAUDE.md`を見て「スキーマファースト」を思い出す → 先に`doc/api-design.md`を更新
2. `backend`を編集するので`.claude/rules/backend.md`が自動で目に入る
   → RFC 9457のエラー形式、`/api/v1/`始まり、ドメインルール（サプライズは隠す等）を踏まえて実装
3. `.claude/rules/testing.md`を踏まえ、RSpecのSpecを先に書く（TDD）
4. ファイルを保存するたびに`post-edit-rubocop.sh`が自動でRuboCopを走らせる
5. コミット前に`/smart-commit`でメッセージを生成、PR作成時に`/pr-description`で本文を生成
6. `.claude/rules/git.md`に従いブランチ名・コミットプレフィックスを揃える
7. PR作成後、CodeRabbitが`.coderabbit.yaml`のドメインルールに基づいてレビューする
   （`backend.md`と同じルールを見ているので、指摘内容がAI実装時の方針とズレない）
8. マージ前に`/code-review`（必要なら`/security-review`）を実行

---

## つまずきやすい点

- **`doc/`と`.claude/rules/`の役割の違い**：`doc/`が正本（仕様そのもの）、`.claude/rules/*.md`は
  「実装中にAIへ直接見せるための抜粋・要約」。詳細な経緯や理由まで知りたいときは`doc/`を見る
- **ドメインルール・用語を変更したときに`.coderabbit.yaml`だけ／`doc/`だけを直して終わらせない**
  （「3箇所同期」を参照）。CIやLintでは検出されないズレなので、レビュー時に気づきにくい
- `.claude/settings.json`のallow/denyは「Claude Codeに対する制限」であって、CIのチェックではない。
  人間が手元でdenyに該当するコマンドを打つこと自体は止まらない（打たない方がよいのは変わらない）
- hooksが自動でLintを走らせてくれるとはいえ、`bundle exec brakeman`・`bundle exec bundler-audit`
  （`.claude/rules/backend.md`参照）は自動化されていないため、コミット前に手動実行が必要
