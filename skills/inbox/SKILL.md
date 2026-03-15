---
name: inbox
description: >
  思いつき・メモ・アイデアをYourOS Inboxに即記録する。
  「/inbox テスト項目を追加」のように使う。プロジェクト紐付けや緊急マークにも対応。
disable-model-invocation: true
allowed-tools: Write, Bash, Read
context: fork
---

# inbox スキル

`$ARGUMENTS` の内容を `/Users/apple/YourOS/Inbox/YYYY/YYYY-MM-DD.md` にタイムスタンプ付きで追記する。

**注意**: このスキルは YourOS Inbox（正本）に直接書き込む。cc-company の secretary/inbox/ への書き込みは行わない。secretary 経由の操作（`/company`）では secretary CLAUDE.md のルールにより自動的に dual-write される。`/inbox` スキルは secretary を経由しない直接入力パスである。

## 引数の処理

`$ARGUMENTS` を解析し、以下のオプションを抽出:

- `p:<project>` → プロジェクト名タグ（任意）。記録にタグを付与し、`/triage` 時の仕分け提案に活用
- `!` プレフィックス → 緊急マーク（任意）。`/inbox ! サーバーが落ちた` のように使う
- 残りの文字列 → 記録する内容（複数行の場合はそのまま保持）

例:
- `/inbox ホームページのデザインを変えたい` → 通常記録
- `/inbox p:homepage-renewal ヒーロー画像の案を3つ考える` → プロジェクトタグ付き
- `/inbox ! 本番DBの接続エラー` → 緊急マーク付き

## 処理フロー

1. 現在の日付から年(YYYY)と日付(YYYY-MM-DD)を取得する
2. `/Users/apple/YourOS/Inbox/YYYY/` ディレクトリが存在しない場合は Bash で `mkdir -p /Users/apple/YourOS/Inbox/YYYY` を実行
3. `/Users/apple/YourOS/Inbox/YYYY/YYYY-MM-DD.md` が存在するか確認:
   - **存在する場合**: Read で読み込み、`## キャプチャ` セクションに追記
   - **存在しない場合**: 以下のテンプレートで新規作成

### 新規ファイルテンプレート

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: inbox
status: active
tags: []
---

# Inbox - YYYY-MM-DD

## キャプチャ

- **HH:MM** | 内容
```

### 追記フォーマット

既存ファイルの `## キャプチャ` セクション末尾に以下を追記:

- 通常: `- **HH:MM** | 内容`
- プロジェクトタグ付き: `- **HH:MM** | [p:project] 内容`
- 緊急マーク付き: `- **HH:MM** | 🔴 内容`
- 両方: `- **HH:MM** | 🔴 [p:project] 内容`

### 複数行入力の処理

`$ARGUMENTS` が複数行の場合（改行を含む場合）:

```markdown
- **HH:MM** | 1行目の内容
  2行目以降はインデントして記載
  3行目も同様
```

## 引数バリデーション

- `$ARGUMENTS` が空の場合: 「記録する内容を指定してください。例: `/inbox APIレート制限の設計を検討`」とユーザーに伝えて終了
- `$ARGUMENTS` がある場合: そのまま記録する

## 出力

追記完了後、以下の形式でユーザーに通知:

- 通常: 「Inbox に記録しました: (内容の先頭30文字)...」
- 緊急マーク付き: 「🔴 緊急アイテムを Inbox に記録しました: (内容の先頭30文字)...」
- プロジェクトタグ付き: 「Inbox に記録しました [p:project]: (内容の先頭30文字)...」

**重要**: すべての出力は日本語で行うこと。
