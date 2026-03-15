---
created: 2026-03-15
updated: 2026-03-15
type: sop
status: active
tags: [a:ops, t:sop]
---

# YourOS 検証チェックリスト

全スキルと構成要素の動作確認用チェックリスト。

## 1. フォルダ構造

- [ ] ~/YourOS/ に11トップレベルディレクトリが存在する
- [ ] .gitignore で Private/ と AI-blocked/ が除外されている
- [ ] pre-commit フックが Private/AI-blocked/ のステージングをブロックする

## 2. CLAUDE.md

- [ ] 200行未満である
- [ ] Folder Map、AI Boundaries、Naming Conventions、Operating Rules が含まれる
- [ ] BLOCKED セクションに PreToolUse フック設置済みと記載

## 3. cc-company (.company/)

- [ ] Secretary、CEO、PM、Engineering、Research、Reviews の6部署が存在する
- [ ] .company/CLAUDE.md に YourOS Storage Integration セクションがある
- [ ] Secretary inbox → YourOS/Inbox/ への dual-write ルールが記載されている

## 4. セキュリティフック

- [ ] /Users/apple/YourOS/SOP/security/block-ai-write.sh が実行可能 (chmod +x)
- [ ] /Users/apple/.claude/settings.json に PreToolUse フックが設定されている
- [ ] AI-blocked/ への Write がブロックされる
- [ ] Private/ への Write がブロックされる
- [ ] 通常ディレクトリへの Write は許可される

## 5. スキル一覧

| # | スキル | パス | 検証方法 |
|---|--------|------|---------|
| 1 | /prompt-review | ~/.claude/skills/prompt-review/ | `/prompt-review 7` でレポート生成 |
| 2 | /inbox | ~/.claude/skills/inbox/ | `/inbox テスト` で Inbox に記録 |
| 3 | /triage | ~/.claude/skills/triage/ | `/triage today` で仕分け提案 |
| 4 | /handoff | ~/.claude/skills/handoff/ | `/handoff テスト` でメモ生成 |
| 5 | /spec | ~/.claude/skills/spec/ | `/spec p:test テスト仕様` でSpec生成 |
| 6 | /task | ~/.claude/skills/task/ | `/task p:test テストタスク` でTask生成 |
| 7 | /next | ~/.claude/skills/next/ | `/next` でTop 3表示 |
| 8 | /decide | ~/.claude/skills/decide/ | `/decide テスト決定 why:テスト` で記録 |
| 9 | /review-diff | ~/.claude/skills/review-diff/ | `/review-diff` でGO/NOGO判定 |
| 10 | /weekly | ~/.claude/skills/weekly/ | `/weekly` で週次レビュー生成 |

## 6. YourOS コマンド一覧（CLAUDE.md記載）

| コマンド | 対応スキル | 状態 |
|---------|-----------|------|
| /inbox | inbox | 実装済み |
| /triage | triage | 実装済み |
| /handoff | handoff | 実装済み |
| /spec | spec | 実装済み |
| /task | task | 実装済み |
| /next | next | 実装済み |
| /decide | decide | 実装済み |
| /review-diff | review-diff | 実装済み |
| /weekly | weekly | 実装済み |
| /prompt-review | prompt-review | 実装済み |
| /company | cc-company plugin | 実装済み |
