# YourOS - Development & Operations OS

Claude Code中心の個人向け開発・業務OS。
「思いつき→記録→整理→実装→検証→記憶」のサイクルを構造化する。

## Folder Map

| Folder | Purpose | AI Access |
|--------|---------|-----------|
| `Projects/` | 進行中プロジェクト（Spec/Tasks/Notes/Context/Links） | read/write |
| `Inbox/` | すべての入口。思いつきを即記録 | read/write |
| `Knowledge/` | 短く要約された"正"（dev/biz/tools） | read/write |
| `SOP/` | 再現可能な手順（dev/ops/security） | read/write |
| `Decisions/` | 意思決定の台帳 | read/write |
| `Prompts/` | プロンプト雛形・スキル設計・定型指示 | read/write |
| `Scratch/` | 作業中一時置き場（Daily/Handoffs/Reviews/Experiments） | read/write |
| `Archive/` | 完了・陳腐化した退避先 | read only |
| `Private/` | 個人情報・機密 | **BLOCKED** |
| `AI-readable/` | AI向け整形済み正本・要約・索引 | read (preferred) |
| `AI-blocked/` | 鍵・契約・顧客生データ | **BLOCKED** |

## AI Boundaries

### Readable (優先参照)
- `AI-readable/`, `Projects/*/Context/`, `Projects/*/Specs/`
- `SOP/`, `Decisions/`, `Knowledge/`, `Prompts/`
- `Archive/` -- 読み取り専用。新規書き込み禁止

### Writable
- `Inbox/`, `Projects/*/Tasks/`, `Projects/*/Notes/`
- `Scratch/`, `Decisions/`, `Knowledge/`, `SOP/`

### BLOCKED (読み書き禁止)
- `AI-blocked/` -- 絶対にRead/Write/Editしない
- `Private/` -- 絶対にRead/Write/Editしない
- PreToolUse フック（`/Users/apple/.claude/settings.json`）が Write/Edit をブロック

## Naming Conventions

| Type | Format | Example |
|------|--------|---------|
| 日次ファイル | `YYYY-MM-DD.md` | `2026-03-15.md` |
| Decision/Spec | `YYYY-MM-DD--slug.md` | `2026-03-15--auth-rate-limit.md` |
| プロジェクトフォルダ | `kebab-case` | `customer-portal` |
| slug | `kebab-case`, 英語 | `login-error-fix` |

## Tags (最大5個)

| Prefix | Usage | Example |
|--------|-------|---------|
| `p:` | プロジェクト | `p:alpha` |
| `a:` | エリア | `a:dev`, `a:biz` |
| `t:` | タイプ | `t:decision`, `t:sop` |
| `s:` | ステータス | `s:active`, `s:done` |
| `risk:` | リスクレベル | `risk:high` |

## Metadata (YAML Frontmatter)

すべてのファイルに以下のfrontmatterを付与:

```yaml
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: inbox|spec|task|decision|sop|knowledge|handoff|index|review
project: project-name
status: draft|active|done|archived
tags: [p:xxx, a:xxx]
---
```

## Operating Rules

1. **追記主義**: 上書きしない。変更は `HH:MM` タイムスタンプ付きで追記。Decisionsは不変: 既存を編集せず新規作成し `overrides:` で参照
2. **1トピック1ファイル**: 1つのファイルに1つのトピックだけ
3. **テンプレ使用**: `_template.md` がある場合はそれに従う
4. **Inbox入口**: すべての思いつきはまずInboxへ（`/inbox`コマンド）
5. **週次整理**: 毎週 `/weekly` でレビューし、完了をArchiveへ
6. **Spec先行**: 差分が一文で言えない変更は `/spec` で仕様化してから実装
7. **Quality Gate**: コミット前に `/review-diff` でGO/NOGO確認

## Codex Authority

重要なマイルストーンでは Codex MCP にレビューを依頼し、承認を得てから次に進む。
Codex は PM（Claude Code）の上位に位置する最終承認者。

## cc-company Integration

`.company/` はcc-companyが生成する組織構造（秘書→CEO→部署）。
- 秘書のInboxは `~/YourOS/Inbox/` にも書き込む
- CEOの意思決定は `~/YourOS/Decisions/` にも記録する
- データの正本は `~/YourOS/` 側

## Available Commands

### 記録・整理

| Command | Purpose |
|---------|---------|
| `/inbox` | 思いつきを即記録（`p:` タグ、`!` 緊急マーク対応） |
| `/triage` | Inboxの整理・昇格（AI提案、`--auto` 一括モード対応） |
| `/search` | YourOS横断検索（`in:` フォルダ指定、`since:` 日付指定対応） |
| `/recall` | トピック別の経緯追跡（Decision チェーン、タイムライン表示） |

### プロジェクト管理

| Command | Purpose |
|---------|---------|
| `/spec` | 仕様化（受入条件自動生成、`type:` 種別、`depends:` 依存関係対応） |
| `/task` | タスク作成（`effort:` 工数、`parent:` サブタスク、重複検出対応） |
| `/done` | タスク完了（status更新、Spec受入条件の照合） |
| `/decide` | 意思決定ログ（`domain:` 分類、`p:` プロジェクト紐付け、重複チェック） |

### 日次・週次ワークフロー

| Command | Purpose |
|---------|---------|
| `/standup` | 日次スタンドアップ（昨日の完了・今日の予定・ブロッカー自動収集） |
| `/next` | 朝のブリーフィング（期限超過・Handoff・Inbox統合、表示件数可変） |
| `/handoff` | 中断・引き継ぎメモ（git状態・変更ファイル・activeタスク自動収集） |
| `/weekly` | 週次レビュー（git履歴・KPI・前週比較・prompt-review統合） |

### 品質・振り返り

| Command | Purpose |
|---------|---------|
| `/review-diff` | diffレビュー（Spec自動検出、結果保存、プロジェクト固有ルール参照） |
| `/prompt-review` | プロンプト運用分析（品質スコア、前回比較、ツールフィルタ、改善提案） |

### 会社OS

| Command | Purpose |
|---------|---------|
| `/company` | 会社OS（秘書窓口） |
