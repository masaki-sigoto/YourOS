# YourOS

Claude Code 中心の個人向け「開発・業務 OS」。
思いつきを即キャプチャし、仕様化 → 実装 → 検証 → 記憶のサイクルを構造化されたフォルダとスラッシュコマンドで回す。

## Overview

```
YourOS/
  Inbox/          … すべての入口。思いつきを即記録
  Projects/       … 進行中プロジェクト（Spec / Tasks / Notes / Context / Links）
  Knowledge/      … 短く要約された正の情報（dev / biz / tools）
  SOP/            … 再現可能な手順書（dev / ops / security）
  Decisions/      … 不変の意思決定ログ
  Prompts/        … プロンプト雛形・スキル設計
  Scratch/        … 作業中の一時置き場（Daily / Handoffs / Reviews / Experiments）
  Archive/        … 完了・陳腐化した退避先（AI 読み取り専用）
  Private/        … 個人情報・機密（AI アクセス BLOCKED）
  AI-readable/    … AI 向け整形済み正本・要約
  AI-blocked/     … 鍵・契約・生データ（AI アクセス BLOCKED）
  .company/       … cc-company 組織構造（秘書→CEO→部署）
```

## Prerequisites

| 項目 | 要件 |
|------|------|
| Claude Code | v1.0 以上（CLI） |
| cc-company | プラグインインストール済み |
| Python | 3.10+（`/prompt-review` の collect.py で使用） |
| Git | 2.x |
| OS | macOS / Linux |

## Setup（セットアップ手順）

### 1. リポジトリのクローン

```bash
cd ~
git clone https://github.com/masaki-sigoto/YourOS.git
```

### 2. スキルのインストール

YourOS は 10 個のスラッシュコマンド（Claude Code Skills）で操作します。
各コマンドは `~/.claude/skills/<name>/SKILL.md` に定義します。

```bash
mkdir -p ~/.claude/skills/{inbox,triage,handoff,spec,task,next,decide,review-diff,weekly,prompt-review}
```

各スキルの SKILL.md は [skills/](skills/) ディレクトリに収録しています（参考用）。
`~/.claude/skills/` にコピーしてください。

> **重要**: SKILL.md 内のパスは `/Users/apple/YourOS/` がハードコードされています。
> 自分の環境に合わせて一括置換してください:
>
> ```bash
> # macOS
> find ~/.claude/skills/ -name "SKILL.md" -exec sed -i '' "s|/Users/apple|${HOME}|g" {} +
> sed -i '' "s|/Users/apple|${HOME}|g" ~/YourOS/CLAUDE.md
>
> # Linux
> find ~/.claude/skills/ -name "SKILL.md" -exec sed -i "s|/Users/apple|${HOME}|g" {} +
> sed -i "s|/Users/apple|${HOME}|g" ~/YourOS/CLAUDE.md
> ```

### 3. cc-company のセットアップ

YourOS ディレクトリで cc-company をオンボーディングします。

```bash
cd ~/YourOS
# Claude Code セッション内で:
# /company
```

初回オンボーディングで `.company/` ディレクトリが生成されます。
生成後、`.company/CLAUDE.md` に **YourOS Storage Integration** セクションを追加し、
秘書の Inbox → `~/YourOS/Inbox/` への dual-write ルールを設定します。

dual-write の例（`.company/CLAUDE.md` に追記）:

```markdown
## YourOS Storage Integration

Secretary が受け取った inbox アイテムは、以下にも書き込む:
- `~/YourOS/Inbox/YYYY/YYYY-MM-DD.md`

CEO の意思決定は、以下にも記録する:
- `~/YourOS/Decisions/YYYY/YYYY-MM-DD--slug.md`
```

### 4. セキュリティフックの設定

AI が `Private/` や `AI-blocked/` に書き込むことを防ぐ PreToolUse フックを設定します。

#### 4-1. フックスクリプトに実行権限を付与

```bash
chmod +x ~/YourOS/SOP/security/block-ai-write.sh
```

#### 4-2. `~/.claude/settings.json` にフックを追加

既存の `settings.json` に以下のセクションをマージしてください:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "/absolute/path/to/YourOS/SOP/security/block-ai-write.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

> `command` の値を自分の環境の絶対パスに置き換えてください。
> 例: `/Users/yourname/YourOS/SOP/security/block-ai-write.sh`

#### 4-3. 動作確認

Claude Code セッション内で:

- `AI-blocked/` への Write → ブロックされること
- `Private/` への Write → ブロックされること
- `Inbox/` への Write → 許可されること

### 5. Git の初期化（クローンでなく新規構築する場合）

```bash
cd ~/YourOS
git init
echo "Private/" >> .gitignore
echo "AI-blocked/" >> .gitignore
echo ".DS_Store" >> .gitignore
git add .
git commit -m "Initialize YourOS"
```

## Skills（スキル一覧）

### 入口系

| コマンド | 説明 | 使い方 |
|---------|------|--------|
| `/inbox` | 思いつきを即記録 | `/inbox APIレート制限の設計を検討` |
| `/triage` | Inbox の仕分け・昇格 | `/triage today` or `/triage all` |
| `/handoff` | 中断時の引き継ぎメモ | `/handoff 認証実装途中` |

### 開発フロー系

| コマンド | 説明 | 使い方 |
|---------|------|--------|
| `/spec` | 仕様書の作成（受入条件付き） | `/spec p:my-project ログイン画面のリデザイン` |
| `/task` | タスクの作成（Spec 連携） | `/task p:my-project バリデーション実装 due:2026-03-20 prio:高` |
| `/next` | 今日の優先タスク Top 3 | `/next` or `/next p:my-project` |
| `/decide` | 意思決定の記録（不変） | `/decide TypeScriptに統一 why:型安全性 follow:移行計画作成` |

### 品質ゲート系

| コマンド | 説明 | 使い方 |
|---------|------|--------|
| `/review-diff` | コミット前の diff レビュー（GO/NOGO） | `/review-diff focus:security spec:Specs/xxx.md` |
| `/weekly` | 週次レビュー生成 | `/weekly` or `/weekly 2026-W11` |
| `/prompt-review` | AI 対話ログの分析レポート | `/prompt-review 7` or `/prompt-review 30` |

### cc-company 統合

| コマンド | 説明 | 使い方 |
|---------|------|--------|
| `/company` | 秘書窓口で日常運営 | `/company 今日のタスクを確認して` |

## Workflow（運用フロー）

### 日常サイクル

```
1. 思いつき → /inbox で即キャプチャ
2. 整理      → /triage today で Inbox を仕分け
3. 確認      → /next で今日の優先タスクを表示
4. 設計      → /spec で仕様化
5. 実装      → /task でタスク管理しながら開発
6. 検証      → /review-diff でコミット前チェック
7. 記録      → /decide で意思決定を記録
8. 中断      → /handoff で引き継ぎメモ
```

### 週次サイクル

```
1. /weekly         → 週次レビュー生成（Archive/Reviews/ に保存）
2. /prompt-review  → プロンプト運用の振り返り（Scratch/Reviews/ に保存）
3. /triage all     → 未処理 Inbox の一掃
```

## Folder Rules（フォルダルール）

### AI アクセス制御

| レベル | フォルダ | 権限 |
|--------|---------|------|
| Read/Write | `Inbox/`, `Projects/*/Tasks/`, `Scratch/`, `Decisions/`, `Knowledge/`, `SOP/` | 読み書き可 |
| Read-only | `Archive/`, `AI-readable/` | 読み取りのみ |
| **BLOCKED** | `Private/`, `AI-blocked/` | 一切アクセス不可（フックで強制） |

### 命名規則

| 種類 | 形式 | 例 |
|------|------|------|
| 日次ファイル | `YYYY-MM-DD.md` | `2026-03-15.md` |
| Decision / Spec | `YYYY-MM-DD--slug.md` | `2026-03-15--auth-rate-limit.md` |
| フォルダ | `kebab-case` | `customer-portal` |
| slug | `kebab-case`（英語） | `login-error-fix` |

### YAML Frontmatter（共通メタデータ）

すべてのファイルに付与:

```yaml
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: inbox|spec|task|decision|sop|knowledge|handoff|review
project: project-name
status: draft|active|done|archived
tags: [p:xxx, a:xxx, t:xxx]
---
```

### タグ体系

| Prefix | 用途 | 例 |
|--------|------|------|
| `p:` | プロジェクト | `p:alpha` |
| `a:` | エリア | `a:dev`, `a:biz` |
| `t:` | タイプ | `t:decision`, `t:sop` |
| `s:` | ステータス | `s:active`, `s:done` |
| `risk:` | リスクレベル | `risk:high` |

## Operating Principles（運用原則）

1. **追記主義** — 上書きしない。変更は `HH:MM` タイムスタンプ付きで追記。Decisions は不変（immutable）
2. **1 トピック 1 ファイル** — 1 つのファイルに 1 つのトピック
3. **テンプレ使用** — `_template.md` があればそれに従う
4. **Inbox 入口** — すべての思いつきはまず `/inbox` で Inbox へ
5. **週次整理** — 毎週 `/weekly` でレビュー
6. **Spec 先行** — diff が一文で言えない変更は `/spec` で仕様化してから実装
7. **Quality Gate** — コミット前に `/review-diff` で GO/NOGO 確認

## Security（セキュリティ）

### PreToolUse フック

`SOP/security/block-ai-write.sh` は Claude Code の PreToolUse フックとして動作します。
Write / Edit ツールが `AI-blocked/` または `Private/` を対象とする場合に自動でブロックします。

**仕組み**:

```
Claude Code が Write/Edit を実行
  → block-ai-write.sh にパスが渡される
  → AI-blocked/ or Private/ を含む → deny（ブロック）
  → それ以外 → allow（許可）
```

### .gitignore

`Private/` と `AI-blocked/` は `.gitignore` で Git 管理から除外されています。
機密データが誤ってコミットされることを防ぎます。

### 注意事項

- フックはデフォルトで「fail-open」（スクリプトエラー時は許可）です
- 厳密な環境では `block-ai-write.sh` の最終行を `exit 2` に変更して「fail-closed」にすることを推奨
- `~/.claude/settings.json` には API キーなどのクレデンシャルが含まれる場合があります。Git にコミットしないでください

## Architecture（アーキテクチャ）

```
┌─────────────────────────────────────────┐
│  User                                   │
│  └─ /inbox, /spec, /task, /next ...     │
├─────────────────────────────────────────┤
│  Claude Code (PM)                       │
│  └─ Skills (~/.claude/skills/*)         │
│     └─ SKILL.md × 10 commands           │
├─────────────────────────────────────────┤
│  YourOS (~/YourOS/)                     │
│  ├─ CLAUDE.md (AI ルール定義)            │
│  ├─ .company/ (cc-company 組織構造)      │
│  └─ 11 Top-level Directories           │
├─────────────────────────────────────────┤
│  Security Layer                         │
│  └─ PreToolUse Hook (block-ai-write.sh) │
│     └─ Private/, AI-blocked/ を保護      │
└─────────────────────────────────────────┘
```

## Customization（カスタマイズ）

### プロジェクトの追加

```bash
mkdir -p ~/YourOS/Projects/my-project/{Context,Specs,Tasks,Notes,Links}
```

または `/spec p:my-project 説明` を実行すると自動でフォルダが作成されます。

### スキルの編集

各スキルの動作は `~/.claude/skills/<name>/SKILL.md` を編集することで変更できます。

主な設定項目:

```yaml
---
name: skill-name
description: スキルの説明
disable-model-invocation: true   # AI の自動判断での実行を無効化
allowed-tools: Read, Write, Bash  # 使用可能なツール
context: fork                     # 隔離コンテキストで実行
---
```

### 新しいスキルの追加

1. `~/.claude/skills/my-skill/SKILL.md` を作成
2. フロントマターに `name`, `description`, `allowed-tools` を定義
3. 処理フローを Markdown で記述
4. 新しい Claude Code セッションを開始するとスキルが認識される

## Verification（動作確認）

セットアップ後の検証コマンド:

```
/inbox テスト: セットアップ確認          → Inbox/YYYY/YYYY-MM-DD.md に記録される
/triage today                          → Inbox の仕分け提案が表示される
/next                                  → 未完了タスクの Top 3 が表示される
/decide テスト環境構築完了 why:動作確認   → Decisions/YYYY/ にファイルが作成される
/handoff セットアップ完了               → Scratch/Handoffs/ にファイルが作成される
```

詳細なチェックリストは [SOP/ops/os-verification.md](SOP/ops/os-verification.md) を参照。

## Related

- [prompt-review_cc-company](https://github.com/masaki-sigoto/prompt-review_cc-company) — YourOS の設計ドキュメント（DeepResearch）
- [Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code/skills) — Skills の仕様
- [cc-company](https://www.npmjs.com/package/cc-company) — Claude Code 仮想会社プラグイン

## License

MIT
