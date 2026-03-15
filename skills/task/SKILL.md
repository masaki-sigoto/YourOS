---
name: task
description: >
  プロジェクトのタスクを作成・更新する。Specとの相互リンクをサポートし、
  優先度・期限を含むタスクファイルを生成する。
allowed-tools: Read, Write, Bash, Grep
context: fork
---

# task スキル

プロジェクトのタスクを `/Users/apple/YourOS/Projects/<project>/Tasks/YYYY-MM-DD--slug.md` に作成する。

## 引数の処理

`$ARGUMENTS` を解析:

- `p:<project>` → プロジェクト名（必須）
- `due:YYYY-MM-DD` → 期限（任意）
- `prio:高|通常|低` → 優先度（任意、デフォルト: 通常）
- `spec:<path>` → 関連Specファイル名（Projects/<project>/ からの相対パス。例: `spec:Specs/2026-03-15--login-redesign.md`）（任意）
- 残りの文字列 → タスク内容

例: `/task p:customer-portal ログインフォームのバリデーション実装 due:2026-03-20 prio:高`

- `p:` が省略された場合 → 「プロジェクト名を指定してください。例: `/task p:my-project タスク内容`」と通知して終了
- タスク内容が空の場合 → 「タスク内容を指定してください」と通知して終了

## slug 生成

タスク内容から slug を生成:
- 英語の場合: スペースをハイフンに変換、小文字化、英数字とハイフンのみ保持
- 日本語の場合: 内容を要約した短い英語 slug を生成
- 先頭・末尾のハイフンは除去、最大30文字

## 処理フロー

1. `/Users/apple/YourOS/Projects/<project>/Tasks/` が存在しない場合は `mkdir -p` で作成
2. タスクファイルを以下のテンプレートで作成
3. `spec:` が指定された場合、`/Users/apple/YourOS/Projects/<project>/<spec:path>` を Read で確認。ファイルが存在すれば `## タスク分解` セクションにこのタスクへのリンクを追記。存在しない場合はバックリンク追記をスキップし「指定された Spec ファイルが見つかりません: (パス)」とユーザーに警告する

## テンプレート

```
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: task
project: <project>
status: active
priority: 高|通常|低
due: YYYY-MM-DD（指定時）
spec: Specへの相対パス（指定時）
tags: [p:<project>]
---

# タスク: タスクタイトル

## 内容

タスクの詳細内容をここに記載。

## 完了条件

- [ ] 条件1
- [ ] 条件2

## メモ

（作業中のメモをここに追記）
```

## 出力

ファイル作成後、以下を通知:
- 作成されたファイルパス
- 優先度と期限（設定されている場合）
- 関連Specへのリンク（設定されている場合）

**重要**: すべての出力は日本語で行うこと。
