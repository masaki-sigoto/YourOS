---
name: handoff
description: >
  作業を中断する際の引き継ぎメモを作成する。
  git状態・変更ファイル・activeタスクを自動収集し、コンテキストを保存する。
allowed-tools: Read, Write, Bash, Grep, Glob
context: fork
---

# handoff スキル

作業中断時の引き継ぎメモを `/Users/apple/YourOS/Scratch/Handoffs/YYYY-MM-DD--slug.md` に作成する。git 状態やアクティブタスクを自動収集して、翌日の自分がすぐに再開できるようにする。

## 引数の処理

`$ARGUMENTS` を解析:

- `p:<project>` → プロジェクト名を明示指定（任意）
- 残りの文字列 → 中断箇所の説明
- 引数なし → 自動コンテキスト収集のみ

slug 生成:
- 説明文字列がある場合 → スペースをハイフンに変換、小文字化、英数字とハイフンのみ保持。先頭・末尾のハイフンは除去。日本語のみや変換結果が空の場合は `session` にフォールバック
- 引数なし → slug は `session`

## 処理フロー

### ステップ1: ディレクトリ準備

`/Users/apple/YourOS/Scratch/Handoffs/` が存在しない場合は Bash で `mkdir -p` を実行。

### ステップ2: 自動コンテキスト収集

以下の情報を Bash/Glob/Read で自動収集する:

1. **git 状態**:
   - `git branch --show-current` → 現在のブランチ名
   - `git status --short` → 変更ファイル一覧（追加/変更/削除）
   - `git diff --stat` → 変更の統計（ファイル数、追加行、削除行）
   - `git log -3 --oneline` → 直近3コミットのメッセージ

2. **プロジェクト推定**（`p:` が指定されていない場合）:
   - ブランチ名にプロジェクト名が含まれるか確認（`feature/homepage-renewal/xxx` → `homepage-renewal`）
   - 変更ファイルのパスから推定（`Projects/homepage-renewal/` 配下のファイルがあるか）
   - 推定できた場合は `project:` に設定

3. **アクティブタスク**:
   - プロジェクトが特定できた場合、`/Users/apple/YourOS/Projects/<project>/Tasks/*.md` をスキャンし、`status: active` のタスク一覧を取得

### ステップ3: ファイル生成

ファイルパス: `/Users/apple/YourOS/Scratch/Handoffs/YYYY-MM-DD--slug.md`
同名ファイルが既にある場合は slug にサフィックス `-2`, `-3` を付与。

## テンプレート

```
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: handoff
project: (推定または指定されたプロジェクト名。不明なら空)
status: active
tags: []
---

# 引き継ぎメモ - YYYY-MM-DD

## 中断箇所

$ARGUMENTS の内容をここに記載。引数がない場合は、git の状態から作業内容を要約して記載する。

## 次にやること

- [ ] （アクティブタスクや変更状態から推定して記載。不明なら「次回セッションで記入」）

## 未解決の問題

- （git diff から未完成と思われる変更を検出した場合に記載。なければ「なし」）

## 関連ファイル

（git status で検出された変更ファイル一覧を自動記載）

- `path/to/modified-file.ts` (変更)
- `path/to/new-file.ts` (新規)
- `path/to/deleted-file.ts` (削除)

## git コンテキスト

- ブランチ: branch-name
- 直近コミット:
  - abc1234 コミットメッセージ1
  - def5678 コミットメッセージ2
  - ghi9012 コミットメッセージ3
- 変更統計: Nファイル変更, +N追加, -N削除

## アクティブタスク（プロジェクト特定時のみ）

- [ ] タスクタイトル1 (prio:高, due:YYYY-MM-DD)
- [ ] タスクタイトル2 (prio:通常)
```

## 出力

ファイル作成後、以下を通知:
- 作成されたファイルパス
- 収集されたコンテキストの概要（ブランチ名、変更ファイル数、アクティブタスク数）
- 「お疲れさまでした。次回は `/next` で再開してください。」

**重要**: すべての出力は日本語で行うこと。
