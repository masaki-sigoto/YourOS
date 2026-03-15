---
name: next
description: >
  今日の最優先タスクを表示する朝のブリーフィング。未完了タスク・期限超過・
  前回の引き継ぎメモ・未処理Inboxを統合して提示する。
allowed-tools: Read, Grep, Glob, Bash
context: fork
---

# next スキル

全プロジェクトまたは指定プロジェクトの未完了タスクをスキャンし、朝のブリーフィング形式で表示する。読み取り専用。

## 引数の処理

`$ARGUMENTS` を解析:

- `p:<project>` → 指定プロジェクトのみスキャン
- 数値（例: `5`） → 表示件数を変更（デフォルト: 3）
- `all` → 全件表示
- 引数なし → 全プロジェクト横断、Top 3

例: `/next p:homepage-renewal 5` → homepage-renewal プロジェクトの上位5件

## 処理フロー

### ステップ1: 引き継ぎメモの確認

1. Glob で `/Users/apple/YourOS/Scratch/Handoffs/*.md` を検索
2. 最新の Handoff ファイル（ファイル名の日付で判定）を Read で読み込む
3. Handoff が存在し、作成日が過去3日以内の場合 → 「中断箇所」セクションをブリーフィングに含める

### ステップ2: タスクのスキャン

1. Glob で `/Users/apple/YourOS/Projects/*/Tasks/*.md` を検索（`_template.md`, `_index.md` は除外）
2. `p:<project>` が指定されている場合は `/Users/apple/YourOS/Projects/<project>/Tasks/*.md` に絞る
3. 各タスクファイルの YAML frontmatter を Read で読み取り:
   - `status: active` のもののみ対象（`done`, `archived` は除外）
   - `priority`, `due`, タスクタイトルを取得

### ステップ3: ソートと分類

タスクを以下のカテゴリに分類:

1. **期限超過**: `due` が今日より前のタスク
2. **今日期限**: `due` が今日のタスク
3. **通常**: 上記以外

各カテゴリ内でのソート順:
- 優先度: 高 > 通常 > 低
- 同優先度内: 期限が近い順（期限なしは最後）

### ステップ4: Inbox の状況確認

1. Glob で `/Users/apple/YourOS/Inbox/**/*.md` を検索
2. 各ファイルの `## キャプチャ` セクション内で、取り消し線（`~~`）や「昇格済み」がついていないアイテムの件数をカウント

## 出力フォーマット

```
おはようございます。今日は YYYY年MM月DD日（曜日）です。

---

（Handoff が存在する場合のみ）
## 前回の引き継ぎ (YYYY-MM-DD)
> 中断箇所の内容をここに引用

---

（期限超過タスクが存在する場合のみ）
## ⚠ 期限超過
1. [高] タスクタイトル (p:project-name, 期限:YYYY-MM-DD — N日超過)
   → パス

---

## 今日の優先タスク

1. [高] タスクタイトル (p:project-name, 期限:YYYY-MM-DD)
   → パス

2. [通常] タスクタイトル (p:project-name)
   → パス

3. [低] タスクタイトル (p:project-name, 期限:YYYY-MM-DD)
   → パス

---

## ステータス
- 全 active タスク: N件
- 期限超過: N件
- 未処理 Inbox: N件 → `/triage` で整理しましょう
```

### 特殊ケース

- タスクが0件の場合: 「未完了のタスクはありません。`/task` で新しいタスクを作成してください。」
- 表示件数がタスク数より多い場合: 存在する分だけ表示
- 期限超過が0件の場合: 「⚠ 期限超過」セクションを省略
- Handoff がない/古い場合: 引き継ぎセクションを省略
- 未処理 Inbox が0件の場合: 「未処理 Inbox: 0件」と表示（`/triage` 案内は省略）

**重要**: すべての出力は日本語で行うこと。
