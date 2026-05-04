# 開発手順

## TDDの手順（この順番を必ず守る）

1. Model Spec（バリデーション・アソシエーション）
2. Request Spec（エンドポイントのテストを先に書く）
3. Controller実装（テストを通す）
4. 必要ならServiceクラスに切り出す

## Specの書き方

- FactoryBotでテストデータを作る（fixtures禁止）
- describe / context は日本語OK
- shared_examplesで重複を減らす
- letを使ってデータ定義を明示的に書く

## Claude Codeへの指示の出し方

新機能を実装するときはこの順番で指示する：
1.「〇〇のModel Specを書いて」
2.「Specを通すモデルを実装して」
3.「〇〇のRequest Specを書いて」
4.「Specを通すControllerを実装して」
5.「ロジックをServiceクラスに切り出して」

## よく使うコマンド

- docker compose exec api bundle exec rspec                          # 全テスト
- docker compose exec api bundle exec rspec spec/models              # モデルのみ
- docker compose exec api bundle exec rspec spec/requests            # APIのみ
- docker compose exec api bundle exec rubocop -A                     # Lint自動修正
- docker compose exec api bundle exec rails db:migrate               # マイグレーション
- docker compose exec api bundle exec rails db:seed                  # シードデータ投入
- docker compose exec api bundle exec rails db:drop db:create db:migrate  # DBリセット（migration変更時）

## やってはいけないこと

- Controllerにビジネスロジックを書かない
- テストなしで実装しない
- マジックナンバーをそのまま書かない（定数化する）
- N+1クエリを放置しない（includesを使う）
- fixturesを使う（FactoryBotを使う）
