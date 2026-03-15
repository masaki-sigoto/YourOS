---
name: decide
description: >
  意思決定を記録する。決定事項、理由、フォローアップを構造化して
  /Users/apple/YourOS/Decisions/ に保存する。
disable-model-invocation: true
allowed-tools: Read, Write, Bash
context: fork
---

# decide スキル

意思決定を `/Users/apple/YourOS/Decisions/YYYY/YYYY-MM-DD--slug.md` に記録する。

## 引数の処理

`$ARGUMENTS` を解析:

- メインテキスト → 決定のタイトル（必須）
- `why:` 以降のテキスト → 決定理由（任意）
- `follow:` 以降のテキスト → フォローアップアクション（任意）

例: `/decide TypeScriptに統一する why:型安全性とDX向上 follow:既存JSファイルの段階的移行計画を作成`

- タイトルが空の場合 → 「決定内容を指定してください。例: `/decide フレームワークをNext.jsに決定 why:理由`」と通知して終了

## slug 生成

タイトルから slug を生成:
- 英語の場合: スペースをハイフンに変換、小文字化、英数字とハイフンのみ保持
- 日本語の場合: 内容を要約した短い英語 slug を生成
- 先頭・末尾のハイフンは除去、最大30文字

## 処理フロー

1. `/Users/apple/YourOS/Decisions/YYYY/` が存在しない場合は作成（Bash で `mkdir -p`）
2. 同名ファイルが既にある場合は slug にサフィックス `-2`, `-3` を付与
3. 以下のテンプレートでファイルを作成

## テンプレート

```
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: decision
status: decided
overrides: ""
tags: []
---

# 決定: タイトル

## 決定事項

タイトルの内容をここに記載。

## 理由

`why:` の内容をここに記載。指定がない場合は「（理由を後日追記）」と記載。

## 代替案

- （検討した代替案があれば記載）

## フォローアップ

- [ ] `follow:` の内容をここに記載。指定がない場合は省略。
```

## 重要ルール

- Decisions は不変（immutable）。一度作成したら編集しない。
- 決定を覆す場合は新しい Decision ファイルを作成し、frontmatter に `overrides: YYYY-MM-DD--previous-slug` を追加する。

## 出力

ファイル作成後、以下を通知:
- 作成されたファイルパス
- 「決定を記録しました。この決定は不変です。覆す場合は新しい `/decide` で `overrides:` を指定してください。」
