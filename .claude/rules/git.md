# Git・ブランチ・PR

## ブランチ

- トランクベース。`master`が唯一のメインブランチ
  - ※CI（`backend/.github/workflows/ci.yml`）に`develop`向けpushトリガーが残っているが、実運用は`master`への直PRになっている。要整理（別チケット）
  - ※既知の課題（別チケット）：`ci.yml`は`backend/.github/workflows/`に置かれているが、GitHub Actionsは`.github/workflows/`をリポジトリルートでしか認識しない。実行履歴0件で、これまで一度も動いていない。移動時に`test`ジョブ（`bin/rails db:test:prepare test`）を`bundle exec rspec`に直すことも合わせて必要
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
  - CLAUDE.md（横断ルール）は「実装中に`doc/`を見に行かせる」ポインタ。`.coderabbit.yaml`と`.claude/rules/backend.md`・`.claude/rules/frontend.md`は「ルールの中身をレビュー時／実装中に直接埋め込む」もの。後者2つは自動追従しないので、**`doc/domain-model.md`や`doc/ubiquitous-language.md`を変更したときは、`.coderabbit.yaml`のpath_instructions・`.claude/rules/backend.md`・`.claude/rules/frontend.md`の3箇所を見直す**
- Request SpecとControllerはセットで1つのPRにする（Specだけだと CI が失敗するため）
- マージ前に `/code-review`、セキュリティが気になる変更は `/security-review` も実行する
