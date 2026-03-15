---
name: review-diff
description: >
  git diffをレビューし、Specの受入条件と照合してGO/NOGO判定を出力する。
  コミット前の品質ゲートとして使用する。
disable-model-invocation: true
allowed-tools: Read, Bash, Grep, Glob
context: fork
---

# review-diff スキル

git diff を取得し、品質チェックを行い、GO/NOGO 判定を出力する。

## 引数の処理

`$ARGUMENTS` を解析:

- `focus:<area>` → レビュー重点領域（例: `focus:security`, `focus:performance`）（任意）
- `spec:<path>` → 照合する Spec ファイルの絶対パス（任意）
- 引数なし → 汎用レビュー

## 処理フロー

1. Bash で `git diff` を取得（ステージ済み: `git diff --cached`, 未ステージ: `git diff`）
2. diff が空の場合は「レビュー対象の変更がありません。」と通知して終了
3. `spec:` が指定されている場合、Read で Spec ファイルを読み込み、`## Acceptance Criteria` を抽出
4. 以下の観点でレビューを実施

## レビュー観点

### 必須チェック（全レビューで実施）

| チェック項目 | 内容 |
|-------------|------|
| セキュリティ | ハードコードされたシークレット、SQL インジェクション、XSS、コマンドインジェクション |
| エラーハンドリング | 未処理の例外、エラーの握りつぶし |
| 型安全性 | any の乱用、型アサーションの不適切な使用（TypeScript の場合） |
| 命名規則 | 一貫性のない命名、略語の乱用 |
| デッドコード | 使用されていないインポート、到達不能コード |

### focus 指定時の追加チェック

| focus | 追加チェック |
|-------|-------------|
| security | 認証・認可のバイパス、入力バリデーション不足、CORS設定 |
| performance | N+1クエリ、不要な再レンダリング、メモリリーク |
| accessibility | aria 属性、キーボード操作、コントラスト |
| testing | テストカバレッジ、エッジケース、モック適切性 |

### Spec 照合（spec: 指定時）

Spec の受入条件（Acceptance Criteria）の各項目について:
- 条件を満たす変更が diff に含まれているか → PASS
- 条件に関連する変更が不足している → WARN
- 条件に反する変更がある → FAIL

## 出力フォーマット

```
== review-diff ==

判定: GO / NOGO

### サマリー
変更ファイル: N個
追加行: +N / 削除行: -N

### チェック結果
- [PASS] セキュリティ: ハードコードされたシークレットなし
- [WARN] エラーハンドリング: catch ブロックでエラーを無視している箇所あり (file.ts:42)
- [FAIL] 型安全性: any が3箇所で使用 (file.ts:10, 25, 78)

### Spec 受入条件（指定時のみ）
- [PASS] 条件1: ログインフォームが表示される
- [WARN] 条件2: バリデーションメッセージの実装が不完全
- [FAIL] 条件3: パスワードリセットリンクが未実装

### 推奨アクション
1. file.ts:42 のエラーハンドリングを修正
2. any を具体的な型に置換

判定根拠: FAIL が1件以上 → NOGO / FAIL なし → GO
```

## 判定ロジック

- **GO**: FAIL が0件（WARN は許容）
- **NOGO**: FAIL が1件以上
