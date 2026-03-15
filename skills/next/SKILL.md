---
name: next
description: >
  今日の最優先タスクTop 3を表示する。全プロジェクトまたは指定プロジェクトの
  未完了タスクをスキャンし、優先度と期限で並び替えて提示する。
allowed-tools: Read, Grep, Glob, Bash
context: fork
---

# next スキル

全プロジェクトまたは指定プロジェクトの未完了タスクをスキャンし、Top 3を表示する。読み取り専用。

## 引数の処理

`$ARGUMENTS` を解析:

- `p:<project>` → 指定プロジェクトのみスキャン
- 引数なし → `/Users/apple/YourOS/Projects/` 配下の全プロジェクトをスキャン

## 処理フロー

1. Glob で `/Users/apple/YourOS/Projects/*/Tasks/*.md` を検索（`_template.md`, `_index.md` は除外）
2. `p:<project>` が指定されている場合は `/Users/apple/YourOS/Projects/<project>/Tasks/*.md` に絞る
3. 各タスクファイルの YAML frontmatter を Read で読み取り:
   - `status: active` のもののみ対象（`done`, `archived` は除外）
   - `priority` と `due` を取得
4. 以下の優先順位でソート:
   - 優先度: 高 > 通常 > 低
   - 同優先度内: 期限が近い順（期限なしは最後）
5. Top 3 を以下の形式で表示

## 出力フォーマット

```
今日の優先タスク:

1. [高] タスクタイトル (プロジェクト:project-name, 期限:YYYY-MM-DD)
   → /Users/apple/YourOS/Projects/project-name/Tasks/YYYY-MM-DD--slug.md

2. [通常] タスクタイトル (プロジェクト:project-name)
   → /Users/apple/YourOS/Projects/project-name/Tasks/YYYY-MM-DD--slug.md

3. [低] タスクタイトル (プロジェクト:project-name, 期限:YYYY-MM-DD)
   → /Users/apple/YourOS/Projects/project-name/Tasks/YYYY-MM-DD--slug.md
```

タスクが0件の場合: 「未完了のタスクはありません。`/task` で新しいタスクを作成してください。」
タスクが3件未満の場合: 存在する分だけ表示する。

**重要**: すべての出力は日本語で行うこと。
タスクが3件未満の場合: 存在する分だけ表示する。
