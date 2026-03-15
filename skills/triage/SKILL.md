---
name: triage
description: >
  YourOS Inboxのアイテムを読み取り、適切な場所（Projects/Knowledge/SOP/Decisions）へ
  昇格（promote）する。対話式で仕分けを行う。
allowed-tools: Read, Write, Bash, Grep, Glob
context: fork
---

# triage スキル

YourOS Inbox のアイテムを読み取り、ユーザーと対話しながら適切な場所に仕分ける。

## 引数の処理

`$ARGUMENTS` を解析:

- `today` または引数なし → 今日の日付 (`/Users/apple/YourOS/Inbox/YYYY/YYYY-MM-DD.md`)
- `YYYY-MM-DD` → 指定日付のファイル
- `all` → `/Users/apple/YourOS/Inbox/` 配下の全ファイルをスキャン（Glob で `**/*.md` を検索）

## 処理フロー

1. 対象の Inbox ファイルを Read で読み込む
2. `## キャプチャ` セクション内の各アイテム（`- **HH:MM** | 内容`）を抽出。取り消し線（`~~`）や「昇格済み」「破棄」マーク付きのアイテムは除外する。未処理アイテムが0件の場合は「Inbox に未処理のアイテムがありません。」と通知して終了
3. 各アイテムについてユーザーに仕分け先を提案:
   - **Projects** → `/Users/apple/YourOS/Projects/<project>/Tasks/` or `/Notes/` に移動
   - **Knowledge** → `/Users/apple/YourOS/Knowledge/<domain>/` に記録
   - **SOP** → `/Users/apple/YourOS/SOP/<area>/` に手順化
   - **Decisions** → `/Users/apple/YourOS/Decisions/YYYY/YYYY-MM-DD--slug.md` に記録
   - **Prompts** → `/Users/apple/YourOS/Prompts/` に保存
   - **Skip** → Inbox に残す（後日再トリアージ）
   - **Discard** → Inbox 内で取り消し線を付けて破棄（`~~内容~~ → 破棄`）。Archive/ は AI 読み取り専用のため書き込まない

4. ユーザーの選択に従い、Write でファイルを作成・追記する
5. 昇格したアイテムは元の Inbox ファイルで `- ~~**HH:MM** | 内容~~ → 昇格済み (行き先)` と取り消し線で更新

## 仕分け提案のロジック

アイテムの内容からキーワードで自動提案:

| キーワード | 提案先 |
|-----------|--------|
| プロジェクト、実装、機能、タスク | Projects |
| 学んだ、メモ、知見、TIL | Knowledge |
| 手順、やり方、セットアップ | SOP |
| 決定、決めた、方針 | Decisions |
| プロンプト、テンプレ、定型 | Prompts |

提案はあくまで候補であり、ユーザーの判断を優先する。

### Decisions 昇格時のテンプレート

Decisions に昇格する場合、以下の frontmatter を使用:

```
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: decision
status: decided
tags: []
---

# 決定: タイトル

## 背景

(Inbox アイテムの内容を展開)

## 決定事項

(ユーザーの入力に基づく)

## 理由

(ユーザーの入力に基づく)
```

## 出力

トリアージ完了後、仕分け結果のサマリーを表示:
```
整理完了:
- プロジェクトに昇格: N件
- ナレッジに記録: N件
- スキップ（Inbox残留）: N件
```

**重要**: すべての出力は日本語で行うこと。仕分け提案や対話もすべて日本語で行う。
