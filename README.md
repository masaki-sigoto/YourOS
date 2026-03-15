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

## Usage Examples（具体的な使い方）

### シナリオ 1: アイデアが浮かんだ → 記録する

散歩中やミーティング中に「あ、あの機能ほしい」と思ったら、すぐにキャプチャ。
後から整理すればいいので、この段階では雑でOK。

```
/inbox ユーザーのプロフィール画像をS3に保存する機能がほしい
/inbox 来週の打ち合わせでAPI設計の方針を決める
/inbox Tailwind v4にアップグレードしたい、breaking changesを調べる
```

生成されるファイル: `Inbox/2026/2026-03-15.md`

```markdown
## キャプチャ

- **09:32** | ユーザーのプロフィール画像をS3に保存する機能がほしい
- **10:15** | 来週の打ち合わせでAPI設計の方針を決める
- **14:03** | Tailwind v4にアップグレードしたい、breaking changesを調べる
```

---

### シナリオ 2: Inbox を整理する → 適切な場所に昇格

1日の終わりや週初めに、溜まった Inbox を仕分けます。
Claude が内容に応じて行き先を提案し、対話しながら振り分けます。

```
/triage today
```

対話例:
```
Claude: 3件の未処理アイテムがあります。

1. "ユーザーのプロフィール画像をS3に保存する機能がほしい"
   → 提案: Projects に昇格（実装タスク）
   仕分け先はどうしますか？ [Projects / Knowledge / SOP / Decisions / Skip / Discard]

You: Projects で。プロジェクト名は customer-portal

2. "来週の打ち合わせでAPI設計の方針を決める"
   → 提案: Skip（まだ具体化していない）

3. "Tailwind v4にアップグレードしたい"
   → 提案: Knowledge に記録（技術調査メモ）
```

---

### シナリオ 3: 新機能を設計する → 仕様書を作る

「何を作るか」をぼんやり決めたら、実装に入る前にまず Spec を書きます。
受入条件（Acceptance Criteria）を定義することで、完了基準が明確になります。

```
/spec p:customer-portal プロフィール画像アップロード機能
```

生成されるファイル: `Projects/customer-portal/Specs/2026-03-15--profile-image-upload.md`

```markdown
# Spec: プロフィール画像アップロード機能

## Background（背景）
ユーザーがプロフィール画像を設定できる機能が必要。

## Acceptance Criteria（受入条件）
- [ ] 画像ファイル（JPG/PNG/WebP）をアップロードできる
- [ ] 5MB以下のファイルサイズ制限がある
- [ ] アップロード後にプレビューが表示される
- [ ] S3に保存され、CDN経由で配信される

## Task Breakdown（タスク分解）
1. S3バケットの設定
2. アップロードAPIエンドポイント
3. フロントエンドのアップロードUI
```

---

### シナリオ 4: 仕様からタスクを切り出す

Spec のタスク分解をもとに、具体的な作業タスクを作ります。
期限や優先度、Spec へのリンクを指定できます。

```
/task p:customer-portal S3バケットとIAMポリシーの設定 due:2026-03-18 prio:高 spec:Specs/2026-03-15--profile-image-upload.md
/task p:customer-portal アップロードAPIの実装 due:2026-03-19 prio:高
/task p:customer-portal フロントエンドUIの実装 due:2026-03-20 prio:通常
```

---

### シナリオ 5: 今日なにやる？ → 優先順位を確認

朝の作業開始時に、全プロジェクト横断で「今やるべきこと」を確認。

```
/next
```

出力例:
```
今日の優先タスク Top 3:

1. [高] S3バケットとIAMポリシーの設定 (p:customer-portal, due:2026-03-18)
   → Projects/customer-portal/Tasks/2026-03-15--s3-bucket-setup.md

2. [高] アップロードAPIの実装 (p:customer-portal, due:2026-03-19)
   → Projects/customer-portal/Tasks/2026-03-15--upload-api.md

3. [通常] フロントエンドUIの実装 (p:customer-portal, due:2026-03-20)
   → Projects/customer-portal/Tasks/2026-03-15--frontend-upload-ui.md
```

特定のプロジェクトだけ見たいとき:
```
/next p:customer-portal
```

---

### シナリオ 6: 技術選定を記録する → 意思決定ログ

「なぜその技術を選んだか」を後から振り返れるように記録します。
Decisions は不変（immutable）。覆す場合は新しい Decision を作ります。

```
/decide 画像ストレージはS3+CloudFrontを使用 why:コスト効率とCDNの低レイテンシ follow:CloudFrontディストリビューションを作成
```

生成されるファイル: `Decisions/2026/2026-03-15--s3-cloudfront-storage.md`

半年後に「なんで S3 にしたんだっけ？」と聞かれても答えられます。

決定を覆す例:
```
/decide 画像ストレージをCloudflare R2に移行 why:S3のエグレス費用が想定以上 follow:R2バケット作成と移行スクリプト
```
→ 新しい Decision ファイルが作成され、前の決定と時系列で追える

---

### シナリオ 7: コミット前に品質チェック

実装が終わったら、コミットする前に diff をレビュー。
セキュリティ問題やバグを自動検出します。

```
/review-diff
```

出力例:
```
== review-diff ==
判定: NOGO

### チェック結果
- [PASS] セキュリティ: ハードコードされたシークレットなし
- [PASS] エラーハンドリング: 適切に処理されている
- [FAIL] 型安全性: any が2箇所で使用 (upload.ts:15, 42)

### 推奨アクション
1. upload.ts:15 の any を具体的な型に置換
2. upload.ts:42 の any を File | null に変更
```

Spec と照合してチェックすることもできる:
```
/review-diff spec:Projects/customer-portal/Specs/2026-03-15--profile-image-upload.md focus:security
```
→ Spec の受入条件を1つずつチェックし、PASS / WARN / FAIL を判定

---

### シナリオ 8: 作業を中断する → 引き継ぎメモ

急な割り込みや退勤時に、現在の状況を記録。
次回（明日の自分、または別のセッション）がスムーズに再開できます。

```
/handoff アップロードAPIのエラーハンドリングを実装中
```

生成されるファイル: `Scratch/Handoffs/2026-03-15--upload-api-error-handling.md`

```markdown
# Handoff - 2026-03-15

## Where I Stopped（中断箇所）
アップロードAPIのエラーハンドリングを実装中

## What's Next（次にやること）
- [ ] （次回セッションで記入）

## Open Questions（未解決の問題）
- （なし）

## Key Files（関連ファイル）
- （次回セッションで記入）
```

次のセッション開始時に `/next` と合わせて見ると、すぐに状況把握できます。

---

### シナリオ 9: 週末に振り返る

金曜日の終わりに、今週やったことを自動集計。
完了タスク、進行中の作業、学びをまとめます。

```
/weekly
```

生成されるファイル: `Archive/Reviews/2026-W11.md`

```markdown
# Weekly Review - 2026-W11
期間: 2026-03-10 (月) 〜 2026-03-16 (日)

## Completed（完了したこと）
- [done] S3バケットとIAMポリシーの設定 (p:customer-portal) — 03-16
- [done] アップロードAPIの実装 (p:customer-portal) — 03-17

## In Progress（進行中）
- [active] フロントエンドUIの実装 (p:customer-portal) — 通常

## Decisions Made（今週の意思決定）
- 画像ストレージはS3+CloudFrontを使用 — 2026-03-15

## Improve（改善したいこと）
- Inbox に3件が未トリアージのまま残っている
```

---

### シナリオ 10: 自分のプロンプトの癖を分析する

過去の AI 対話ログを分析し、プロンプティングの改善点を見つけます。

```
/prompt-review 30
```

過去30日分の Claude Code / GitHub Copilot / Cline 等のログを収集し分析。
レポートは `Scratch/Reviews/prompt-review-2026-03-15.md` に出力されます。

分析内容:
- 技術理解度マップ（熟知 / 基本理解 / 学習中）
- プロンプティングパターン（効果的なパターン / 改善可能なパターン）
- AI 依存度（主体的に方針を決めているか、AI に丸投げしているか）
- 成長の軌跡（時系列でのプロンプト品質の変化）

---

### 日常の流れまとめ

```
朝:   /next            → 今日やることを確認
作業中: /inbox 思いついたこと → 割り込みアイデアをキャプチャ
設計:  /spec p:xxx 説明    → 実装前に仕様化
実装:  /task p:xxx タスク   → タスクを切って進める
決定:  /decide 方針 why:理由 → 技術選定を記録
検証:  /review-diff        → コミット前チェック
退勤:  /handoff 状況       → 引き継ぎメモ
金曜:  /weekly             → 週次振り返り
月末:  /prompt-review 30   → プロンプト品質の分析
```

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
