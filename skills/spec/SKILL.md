---
name: spec
description: >
  プロジェクトの仕様書を作成する。受入条件・タスク分解・リスクを含む構造化された
  Specドキュメントを生成し、実装前の設計を明確にする。
disable-model-invocation: true
allowed-tools: Read, Write, Bash, Grep, Glob
context: fork
---

# spec スキル

プロジェクトの仕様書を `/Users/apple/YourOS/Projects/<project>/Specs/YYYY-MM-DD--slug.md` に作成する。

## 引数の処理

`$ARGUMENTS` を解析:

- `p:<project>` → プロジェクト名（必須）
- 残りの文字列 → 仕様の説明（slug 生成に使用）

例: `/spec p:customer-portal ログイン画面のリデザイン`
→ project=`customer-portal`, slug=`login-redesign`, 説明=「ログイン画面のリデザイン」

- `p:` が省略された場合 → 「プロジェクト名を指定してください。例: `/spec p:my-project 機能の説明`」と通知して終了
- 説明が空の場合 → 「仕様の説明を指定してください」と通知して終了

## slug 生成

説明文から slug を生成:
- 英語の場合: スペースをハイフンに変換、小文字化、英数字とハイフンのみ保持
- 日本語の場合: 内容を要約した短い英語 slug を生成（例: 「ログイン画面」→ `login-screen`）
- 先頭・末尾のハイフンは除去
- 最大30文字

## 処理フロー

1. `/Users/apple/YourOS/Projects/<project>/` が存在しない場合:
   - `/Users/apple/YourOS/Projects/<project>/Context/`, `Specs/`, `Tasks/`, `Notes/`, `Links/` を `mkdir -p` で作成
   - `/Users/apple/YourOS/Projects/_index.md` を Read で読み込み、テーブル末尾に以下の行を追記:
     `| <project> | active | YYYY-MM-DD | — | — |`
2. `/Users/apple/YourOS/Projects/<project>/Specs/YYYY-MM-DD--slug.md` を以下のテンプレートで作成

## テンプレート

```
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: spec
project: <project>
status: draft
tags: [p:<project>, t:spec]
---

# 仕様書: タイトル（説明文から生成）

## 背景

なぜこの変更が必要か。現状の問題点やユーザーの要求を記述する。

## 目的

この仕様が達成すべきゴールを1-3文で明確に記述する。

## スコープ外

- この仕様では扱わないことを明示する

## 受入条件

- [ ] 条件1: 具体的で検証可能な基準
- [ ] 条件2: 具体的で検証可能な基準
- [ ] 条件3: 具体的で検証可能な基準

## タスク分解

1. タスク1
2. タスク2
3. タスク3

## 検証方法

どのようにして受入条件を満たしたことを確認するか。

## リスク

| リスク | 影響度 | 対策 |
|--------|--------|------|
| リスク1 | 高/中/低 | 対策内容 |
```

## 出力

ファイル作成後、以下を通知:
- 作成されたファイルパス
- 「仕様書のドラフトを作成しました。内容を確認・編集してから status を active に変更してください。」

**重要**: すべての出力は日本語で行うこと。
