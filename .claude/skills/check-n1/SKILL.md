---
description: N+1クエリが発生しそうなコードを検出して報告する
---

Controller・Service・Model のコードを読み、N+1 クエリが発生している箇所または発生しそうな箇所を検出して報告する。

## チェック対象

- ループ内（`each` / `map` など）でアソシエーションを参照しているコード
- `includes` / `preload` / `eager_load` なしで関連モデルを呼び出しているコード
- Serializer でアソシエーションを展開しているのに Controller で eager load していない箇所

## 報告フォーマット

問題箇所をファイル・行番号とともに列挙し、修正案（`includes` の追加など）を提示する。

```
[N+1の疑い] app/controllers/api/v1/spots_controller.rb:12
  spots.each { |s| s.tags }  # tags が都度クエリ発生
→ 修正案: Spot.includes(:tags)
```

## 対象ファイル

指定がなければ以下を対象にする:
- `app/controllers/`
- `app/services/`
- `app/serializers/`
