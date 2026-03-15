---
name: weekly
description: >
  過去7日間のYourOS活動を読み取り、週次レビューを生成する。
  完了タスク、進行中の作業、学び、来週の目標をまとめる。
allowed-tools: Read, Write, Bash, Grep, Glob
context: fork
---

# weekly スキル

過去7日間の YourOS 活動をスキャンし、週次レビューを `/Users/apple/YourOS/Archive/Reviews/YYYY-WXX.md` に生成する。

## 引数の処理

`$ARGUMENTS` を解析:

- 引数なし → 今週（現在のISO週番号）
- `YYYY-WXX` → 指定週

## 処理フロー

1. 対象週の日付範囲を特定（月曜〜日曜）
2. 以下のソースをスキャンして情報を収集:

### スキャン対象

| ソース | パス | 収集内容 |
|--------|------|---------|
| Inbox | `/Users/apple/YourOS/Inbox/YYYY/*.md` | 対象週に作成・更新されたキャプチャ |
| Tasks | `/Users/apple/YourOS/Projects/*/Tasks/*.md` | status が done/active のタスク（frontmatter の updated を参照） |
| Decisions | `/Users/apple/YourOS/Decisions/YYYY/*.md` | 対象週に作成された意思決定 |
| Handoffs | `/Users/apple/YourOS/Scratch/Handoffs/*.md` | 対象週のハンドオフメモ |
| Specs | `/Users/apple/YourOS/Projects/*/Specs/*.md` | 対象週に作成・更新された仕様書 |

3. `/Users/apple/YourOS/Archive/Reviews/` が存在しない場合は `mkdir -p` で作成
4. 以下のテンプレートでレビューファイルを生成

## テンプレート

```
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: review
status: active
tags: [t:review]
---

# 週次レビュー - YYYY-WXX

期間: YYYY-MM-DD (月) 〜 YYYY-MM-DD (日)

## 完了したこと

対象週に status が done に変わったタスクを一覧表示。
- [完了] タスク名 (p:project-name) — 完了日

完了タスクがない場合: 「今週完了したタスクはありませんでした。」

## 進行中

status が active のタスクを一覧表示。
- [進行中] タスク名 (p:project-name) — 優先度

## Inbox の状況

- 未処理アイテム数: N件
- 今週追加: N件

## 今週の意思決定

対象週に作成された Decision ファイルを一覧表示。
- 決定タイトル — YYYY-MM-DD

## 良かったこと

収集した情報から推察される、うまくいった点を記述。

## 改善したいこと

未完了タスクの傾向、Inbox の滞留、繰り返しパターンから改善点を提案。

## 学び

Knowledge/ に追加された新しい知見があれば記載。

## 来週の目標

- [ ] 進行中タスクのうち優先度が高いもの Top 3
- [ ] 未トリアージの Inbox アイテムの処理
```

## 出力

ファイル作成後、以下を通知:
- 作成されたファイルパス
- 完了タスク数、進行中タスク数、未処理Inboxアイテム数のサマリー

**重要**: すべての出力は日本語で行うこと。
