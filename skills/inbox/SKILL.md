---
name: inbox
description: >
  思いつき・メモ・アイデアをYourOS Inboxに即記録する。
  「/inbox テスト項目を追加」のように使う。
disable-model-invocation: true
allowed-tools: Write, Bash, Read
context: fork
---

# inbox スキル

`$ARGUMENTS` の内容を `/Users/apple/YourOS/Inbox/YYYY/YYYY-MM-DD.md` にタイムスタンプ付きで追記する。

**注意**: このスキルは YourOS Inbox（正本）に直接書き込む。cc-company の secretary/inbox/ への書き込みは行わない。secretary 経由の操作（`/company`）では secretary CLAUDE.md のルールにより自動的に dual-write される。`/inbox` スキルは secretary を経由しない直接入力パスである。

## 処理フロー

1. 現在の日付から年(YYYY)と日付(YYYY-MM-DD)を取得する
2. `/Users/apple/YourOS/Inbox/YYYY/` ディレクトリが存在しない場合は Bash で `mkdir -p /Users/apple/YourOS/Inbox/YYYY` を実行
3. `/Users/apple/YourOS/Inbox/YYYY/YYYY-MM-DD.md` が存在するか確認:
   - **存在する場合**: Read で読み込み、`## キャプチャ` セクションに追記
   - **存在しない場合**: 以下のテンプレートで新規作成

### 新規ファイルテンプレート

```
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: inbox
status: active
tags: []
---

# Inbox - YYYY-MM-DD

## キャプチャ

- **HH:MM** | $ARGUMENTS の内容
```

### 追記フォーマット

既存ファイルの `## キャプチャ` セクション末尾に以下を追記:

```
- **HH:MM** | $ARGUMENTS の内容
```

## 引数

- `$ARGUMENTS` が空の場合: 「記録する内容を指定してください。例: `/inbox APIレート制限の設計を検討`」とユーザーに伝えて終了
- `$ARGUMENTS` がある場合: そのまま記録する

## 出力

追記完了後、「Inbox に記録しました: (内容の先頭30文字)...」とユーザーに通知する。
