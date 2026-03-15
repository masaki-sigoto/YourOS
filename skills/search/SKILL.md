---
name: search
description: >
  YourOS全体を横断検索する。Decisions/Knowledge/Specs/Tasks/Inbox/SOP を
  キーワードで一括検索し、関連する情報をまとめて表示する。
allowed-tools: Read, Grep, Glob, Bash
context: fork
---

# search スキル

YourOS のフォルダを横断してキーワード検索し、関連する情報をまとめて表示する。読み取り専用。

## 引数の処理

`$ARGUMENTS` を解析:

- メインテキスト → 検索キーワード（必須）
- `in:<folder>` → 検索対象フォルダを限定（任意。複数指定可。例: `in:Decisions in:Knowledge`）
- `since:YYYY-MM-DD` → 指定日以降に作成・更新されたファイルに限定（任意）

例:
- `/search Next.js` → 全フォルダから "Next.js" を検索
- `/search 認証 in:Decisions in:Knowledge` → Decisions と Knowledge のみ検索
- `/search API設計 since:2026-03-01` → 3月以降のファイルから検索

引数バリデーション:

- キーワードが空の場合 → 「検索キーワードを指定してください。例: `/search Next.js`」と通知して終了

## 検索対象フォルダ

`in:` が指定されていない場合、以下の全フォルダを検索（AI アクセス可能なもののみ）:

| 優先度 | フォルダ | 説明 |
| ------ | -------- | ---- |
| 1 | `Decisions/` | 意思決定ログ |
| 2 | `Knowledge/` | 知見・ナレッジ |
| 3 | `Projects/*/Specs/` | 設計書 |
| 4 | `Projects/*/Tasks/` | タスク |
| 5 | `Projects/*/Notes/` | プロジェクトメモ |
| 6 | `SOP/` | 手順書 |
| 7 | `Prompts/` | プロンプト雛形 |
| 8 | `Inbox/` | 未整理メモ |
| 9 | `Scratch/` | 作業メモ |
| 10 | `Archive/` | アーカイブ |

**検索除外**: `Private/`, `AI-blocked/` は絶対に検索しない。

## 処理フロー

1. 検索キーワードと対象フォルダを確定
2. 各フォルダに対して Grep でキーワード検索を実行（大文字小文字を区別しない）
3. `since:` が指定されている場合、YAML frontmatter の `created:` または `updated:` を確認してフィルタ
4. 結果をフォルダ種別ごとにグループ化
5. 各ヒットについてファイルのタイトル（`# ` で始まる最初の行）とマッチ行のコンテキスト（前後1行）を表示

## 出力フォーマット

```
"Next.js" の検索結果: N件

### Decisions (2件)
1. **フレームワークはNext.jsを採用する** — 2026-03-15
   → Decisions/2026/2026-03-15--adopt-nextjs.md
   > ...SSRが必要で、Vercelとの相性が良いため...

2. **フレームワークをRemixに変更** — 2026-03-20
   → Decisions/2026/2026-03-20--switch-to-remix.md
   > ...Next.jsのApp Routerが不安定だったため...

### Knowledge (1件)
1. **Next.js vs Remix 比較メモ** — 2026-03-16
   → Knowledge/dev/2026-03-16--nextjs-vs-remix.md
   > ...ルーティング方式の違い...

### Tasks (1件)
1. **Next.jsの初期セットアップ** — p:homepage-renewal
   → Projects/homepage-renewal/Tasks/2026-03-15--nextjs-setup.md
   > ...npx create-next-app...
```

ヒットが0件の場合: 「"キーワード" に一致する情報は見つかりませんでした。」

**重要**: すべての出力は日本語で行うこと。
