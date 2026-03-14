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
- セキュリティフック（Day 6で設置予定）で自動ブロック

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

| Command | Purpose |
|---------|---------|
| `/inbox` | 思いつきを即記録 |
| `/triage` | Inboxの整理・昇格 |
| `/handoff` | 中断・引き継ぎメモ |
| `/spec` | 仕様化（受入条件付き） |
| `/task` | タスク作成・更新 |
| `/next` | 今日の最優先3つ |
| `/decide` | 意思決定ログ |
| `/review-diff` | diffレビュー（GO/NOGO） |
| `/weekly` | 週次レビュー |
| `/prompt-review` | プロンプト運用分析 |
| `/company` | 会社OS（秘書窓口） |
