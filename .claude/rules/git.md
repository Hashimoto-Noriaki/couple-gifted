# Git・ブランチ・PR

## ブランチ

- トランクベース。`master`が唯一のメインブランチ
- CIは`.github/workflows/ci.yml`（リポジトリルート）。`backend`はモノレポのサブディレクトリなので、Ruby関連のjob（`scan_ruby`・`lint`・`test`）は`working-directory: backend`を指定している
- ブランチ名は `<prefix>/<kebab-case説明>`。prefixはコミット・PRと同じ語彙（`feat` / `test` / `fix` / `chore` / `refactor` / `docs`）を使う
  - 例：`feat/review-post`、`fix/n-plus-one`、`chore/harness-rules`
  - 過去に`doc/xxx`表記のブランチがあるが、コミットプレフィックスは`docs`なので今後は`docs/`に揃える

## コミット

- コミットは機能・テスト・設定ごとに細かく分ける
- プレフィックス: `feat` / `test` / `fix` / `chore` / `refactor` / `docs`
- テストだけの変更は`test:`、実装込みは`feat:`
- ファイルはできる限りジェネレータ（`rails generate`等）で作る。マイグレーションも直接作成しない

## PR

- PRタイトルもコミットと同じプレフィックス規則に従う
- **CodeRabbitのレビューを確認してからマージする**（`.coderabbit.yaml`にドメインルールを踏まえたレビュー観点を設定済み）
  - CLAUDE.md（横断ルール）は「実装中に`doc/`を見に行かせる」ポインタ。`.coderabbit.yaml`と`.claude/rules/backend.md`・`.claude/rules/frontend.md`は「ルールの中身をレビュー時／実装中に直接埋め込む」もの。後者2つは自動追従しないので、正本を変更したら対応する2箇所も見直す（**3箇所を同期させる**）：
    - `doc/domain-model.md`（ドメインルール）を変更したら → `.coderabbit.yaml`のpath_instructions・`.claude/rules/backend.md`
    - `doc/ubiquitous-language.md`（用語）を変更したら → `.coderabbit.yaml`のpath_instructions・`.claude/rules/frontend.md`
- Request SpecとControllerはセットで1つのPRにする（Specだけだと CI が失敗するため）
- マージ前に `/code-review`、セキュリティが気になる変更は `/security-review` も実行する
