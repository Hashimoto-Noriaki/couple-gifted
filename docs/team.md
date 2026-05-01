# チーム開発方針

## ブランチ戦略（GitHub Flow）

- feature/xxxx  機能追加
- fix/xxxx      バグ修正
- hotfix/xxxx   緊急バグ修正
- refactor/xxxx リファクタ
- docs/xxxx     ドキュメント
- chore/xxxx    設定変更

## コミットメッセージ規約

- feat:     新機能追加
- fix:      バグ修正
- hotfix:   緊急バグ修正
- test:     テスト追加・修正
- refactor: リファクタリング
- docs:     ドキュメント更新
- chore:    設定・ツール変更

## 将来のチーム役割想定

- 自分（現在）    バックエンド（Rails）・アーキテクチャ設計
- 将来メンバーA   フロントエンド（Next.js / Nuxt.js・未定）
- 将来メンバーB   デザイン／UI（Figma）
- 将来メンバーC   インフラ（AWS / Render）

## AI駆動開発

- Claude Code    実装支援（ターミナル・VSCode両方）
- CodeRabbit     PR自動レビュー
- CLAUDE.md      チームのルール・規約をAIに読ませる

## PRルール

- PRを出したらCodeRabbitのレビューを確認してからマージ
- GitHub Actions（CI）でRSpecが通ることを確認してからマージ
