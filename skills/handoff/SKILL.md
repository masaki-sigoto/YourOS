---
name: handoff
description: >
  作業を中断する際の引き継ぎメモを作成する。
  現在の状況、次にやること、未解決の問題をまとめて記録する。
disable-model-invocation: true
allowed-tools: Read, Write, Bash
context: fork
---

# handoff スキル

作業中断時の引き継ぎメモを `/Users/apple/YourOS/Scratch/Handoffs/YYYY-MM-DD--slug.md` に作成する。

## 引数の処理

`$ARGUMENTS` を解析:

- 引数あり → slug として使用（スペースはハイフンに変換、小文字化、英数字とハイフンのみ保持。先頭・末尾のハイフンは除去。日本語のみの場合や変換結果が空の場合は slug を `session` にフォールバック）
- 引数なし → slug は `session` とする

## 処理フロー

1. `/Users/apple/YourOS/Scratch/Handoffs/` ディレクトリが存在しない場合は Bash で `mkdir -p /Users/apple/YourOS/Scratch/Handoffs` を実行
2. 現在の日付を取得し、ファイルパスを決定: `/Users/apple/YourOS/Scratch/Handoffs/YYYY-MM-DD--slug.md`
3. 同名ファイルが既にある場合は slug にサフィックス `-2`, `-3` を付与
4. 以下のテンプレートで Write でファイルを作成

## テンプレート

```
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: handoff
project: ""
status: active
tags: []
---

# Handoff - YYYY-MM-DD

## Where I Stopped（中断箇所）

$ARGUMENTS の内容をここに記載。引数がない場合は「（未記入 — 次回セッション開始時に確認してください）」と記載。

## What's Next（次にやること）

- [ ] （次回セッションで記入）

## Open Questions（未解決の問題）

- （なし、または次回セッションで記入）

## Key Files（関連ファイル）

- （次回セッションで記入）
```

## 出力

ファイル作成後、「ハンドオフを記録しました: (ファイルパス)」とユーザーに通知する。
