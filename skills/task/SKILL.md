---
name: task
description: >
  プロジェクトのタスクを作成・更新する。Specとの相互リンク・サブタスク・
  工数見積もり・重複検出をサポートする。
allowed-tools: Read, Write, Bash, Grep, Glob
context: fork
---

# task スキル

プロジェクトのタスクを `/Users/apple/YourOS/Projects/<project>/Tasks/YYYY-MM-DD--slug.md` に作成する。

## 引数の処理

`$ARGUMENTS` を解析:

- `p:<project>` → プロジェクト名（必須）
- `due:YYYY-MM-DD` → 期限（任意）
- `prio:高|通常|低` → 優先度（任意、デフォルト: 通常）
- `effort:S|M|L|XL` → 工数見積もり（任意）
- `spec:<path>` → 関連Specファイル名（Projects/<project>/ からの相対パス。例: `spec:Specs/2026-03-15--login-redesign.md`）（任意）
- `parent:<slug>` → 親タスクの slug（サブタスク作成時）（任意）
- 残りの文字列 → タスク内容

例:
- `/task p:customer-portal ログインフォームのバリデーション実装 due:2026-03-20 prio:高`
- `/task p:customer-portal メール形式チェック追加 parent:login-validation effort:S`

引数バリデーション:

- `p:` が省略された場合 → 「プロジェクト名を指定してください。例: `/task p:my-project タスク内容`」と通知して終了
- タスク内容が空の場合 → 「タスク内容を指定してください」と通知して終了

## slug 生成

タスク内容から slug を生成:
- 英語の場合: スペースをハイフンに変換、小文字化、英数字とハイフンのみ保持
- 日本語の場合: 内容を要約した短い英語 slug を生成
- 先頭・末尾のハイフンは除去、最大30文字

## 処理フロー

### ステップ1: 重複チェック

1. `/Users/apple/YourOS/Projects/<project>/Tasks/*.md` を Glob で検索
2. 各タスクのタイトルとキーワードを比較し、類似タスクがないか確認
3. 類似タスクが見つかった場合:

```
類似するタスクが見つかりました:
- 「ログインフォームのバリデーション」(status: active, 2026-03-15)
  → Projects/customer-portal/Tasks/2026-03-15--login-validation.md

新しいタスクを作成しますか？
```

4. ユーザーが確認後、作成を続行

### ステップ2: タスクファイルの作成

1. `/Users/apple/YourOS/Projects/<project>/Tasks/` が存在しない場合は `mkdir -p` で作成
2. タスクファイルを以下のテンプレートで作成

### ステップ3: Spec との相互リンク

`spec:` が指定された場合:
1. `/Users/apple/YourOS/Projects/<project>/<spec:path>` を Read で確認
2. ファイルが存在すれば `## タスク分解` セクションにこのタスクへのリンクを追記
3. 存在しない場合はバックリンク追記をスキップし「指定された Spec ファイルが見つかりません: (パス)」とユーザーに警告

### ステップ4: 親タスクとのリンク

`parent:` が指定された場合:
1. 親タスクファイルを slug で検索
2. 親タスクの `## サブタスク` セクション（なければ作成）にこのタスクへのリンクを追記
3. 親タスクが見つからない場合は警告

## テンプレート

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: task
project: <project>
status: active
priority: 高|通常|低
due: YYYY-MM-DD（指定時）
effort: S|M|L|XL（指定時）
spec: Specへの相対パス（指定時）
parent: 親タスクのslug（指定時）
tags: [p:<project>]
---

# タスク: タスクタイトル

## 内容

タスクの詳細内容をここに記載。

## 完了条件

- [ ] 条件1
- [ ] 条件2

## サブタスク（parent指定されたサブタスクがある場合のみ）

- [ ] [サブタスク名](パス)

## メモ

（作業中のメモをここに追記）
```

### effort の目安

| 値 | 目安 | 説明 |
| -- | ---- | ---- |
| S | 〜1時間 | 小さな修正、設定変更 |
| M | 半日程度 | 標準的な機能追加 |
| L | 1〜2日 | 複数ファイルにまたがる変更 |
| XL | 3日以上 | 大規模な機能、設計変更を伴う |

## 出力

ファイル作成後、以下を通知:
- 作成されたファイルパス
- 優先度と期限（設定されている場合）
- 工数見積もり（設定されている場合）
- 関連Specへのリンク（設定されている場合）
- 親タスク（設定されている場合）

**重要**: すべての出力は日本語で行うこと。
