# couple-gifted

カップル・夫婦向けのライフプラットフォーム。

## ディレクトリ構成

- [`doc/`](./doc) — 要件定義・ユーザーストーリー・ユースケース・ユビキタス言語などのドキュメント
- [`frontend/`](./frontend) — フロントエンド（Next.js）。セットアップ・開発コマンドは [`frontend/README.md`](./frontend/README.md) を参照
- [`backend/`](./backend) — バックエンド（Rails API）。セットアップ・開発コマンドは [`backend/README.md`](./backend/README.md) を参照

## 開発方針

- **TDD**：Specを先に書いてから実装する
- **スキーマファースト（APIファースト）**：エンドポイントを追加・変更するときは、先に [`doc/api-design.md`](./doc/api-design.md)・[`doc/api/openapi.yaml`](./doc/api/openapi.yaml) を更新してから実装する

詳細は [`CLAUDE.md`](./CLAUDE.md) を参照。

## ドキュメント

- [要件定義](./doc/requirements.md)
- [ユーザーストーリー](./doc/user-stories.md)
- [ユースケース](./doc/use-cases.md)
- [ドメインモデル](./doc/domain-model.md)
- [ユビキタス言語](./doc/ubiquitous-language.md)
- [ER図・DB設計](./doc/er-and-db-design.md)
- [API設計](./doc/api-design.md) / [OpenAPIスキーマ](./doc/api/openapi.yaml)
- [画面遷移図](./doc/screen-flow.md) / [ワイヤーフレーム](./doc/wireframes.md)
- [Claude Codeの設定ガイド（CLAUDE.md・.claude/）](./doc/claude-code-guide.md)

## POC
https://github.com/Hashimoto-Noriaki/couple-gifted-poc
