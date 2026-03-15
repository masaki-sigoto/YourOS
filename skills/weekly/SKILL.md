---
name: weekly
description: >
  過去7日間のYourOS活動とgitコミットを読み取り、データドリブンな週次レビューを生成する。
  トレンド比較・KPI・prompt-review統合に対応。
allowed-tools: Read, Write, Bash, Grep, Glob
context: fork
---

# weekly スキル

過去7日間の YourOS 活動をスキャンし、週次レビューを `/Users/apple/YourOS/Archive/Reviews/YYYY-WXX.md` に生成する。

## 引数の処理

`$ARGUMENTS` を解析:

- 引数なし → 今週（現在のISO週番号）
- `YYYY-WXX` → 指定週

## 処理フロー

### ステップ1: 日付範囲の特定

対象週の日付範囲を特定（月曜〜日曜）。

### ステップ2: データ収集

以下のソースをスキャンして情報を収集:

| ソース | パス | 収集内容 |
| ------ | ---- | -------- |
| Inbox | `/Users/apple/YourOS/Inbox/YYYY/*.md` | 対象週に作成・更新されたキャプチャ |
| Tasks | `/Users/apple/YourOS/Projects/*/Tasks/*.md` | status が done/active のタスク（frontmatter の updated を参照） |
| Decisions | `/Users/apple/YourOS/Decisions/YYYY/*.md` | 対象週に作成された意思決定 |
| Handoffs | `/Users/apple/YourOS/Scratch/Handoffs/*.md` | 対象週のハンドオフメモ |
| Specs | `/Users/apple/YourOS/Projects/*/Specs/*.md` | 対象週に作成・更新された仕様書 |
| Knowledge | `/Users/apple/YourOS/Knowledge/**/*.md` | 対象週に作成・更新された知見 |
| Reviews | `/Users/apple/YourOS/Scratch/Reviews/review-*.md` | 対象週のコードレビュー結果 |

### ステップ3: git コミット履歴の収集

Bash で以下を実行し、開発活動の定量データを取得:

```bash
git log --since="YYYY-MM-DD" --until="YYYY-MM-DD" --oneline --shortstat
```

収集項目:
- コミット数
- 変更ファイル数（合計）
- 追加行数 / 削除行数
- アクティブなブランチ一覧

### ステップ4: 前週比較データの取得

前週のレビューファイル `/Users/apple/YourOS/Archive/Reviews/YYYY-W(XX-1).md` が存在する場合、Read で読み込んで以下を比較:

- 完了タスク数の変化
- Inbox 滞留の変化
- 新規 Decision 数の変化

### ステップ5: KPI の算出

| KPI | 算出方法 | 説明 |
| --- | -------- | ---- |
| タスク完了率 | 完了数 / (完了数 + active数) | 今週のタスク消化効率 |
| Inbox 滞留日数 | 最も古い未処理アイテムの経過日数 | 整理の滞り具合 |
| Spec→Task 変換率 | タスク化された Spec 受入条件数 / 総受入条件数 | 設計の実装への反映度 |
| レビュー合格率 | OK 判定数 / 総レビュー数 | コード品質の傾向 |

### ステップ6: レビューファイル生成

`/Users/apple/YourOS/Archive/Reviews/` が存在しない場合は `mkdir -p` で作成。

## テンプレート

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: review
status: active
tags: [t:review]
---

# 週次レビュー - YYYY-WXX

期間: YYYY-MM-DD (月) 〜 YYYY-MM-DD (日)

## KPI サマリー

| 指標 | 今週 | 前週 | 変化 |
| ---- | ---- | ---- | ---- |
| タスク完了数 | N件 | N件 | +N / -N |
| タスク完了率 | N% | N% | +N% / -N% |
| Inbox 未処理 | N件 | N件 | +N / -N |
| Inbox 最大滞留 | N日 | N日 | — |
| コードレビュー | N回 (OK: N / NG: N) | — | — |
| git コミット | N件 (+N行 / -N行) | — | — |

（前週データがない場合は「前週」「変化」列を「—」にする）

## 完了したこと

対象週に status が done に変わったタスクを一覧表示。

- [完了] タスク名 (p:project-name) — 完了日

完了タスクがない場合: 「今週完了したタスクはありませんでした。」

## 進行中

status が active のタスクを一覧表示。

- [進行中] タスク名 (p:project-name) — 優先度, 工数見積もり

## Inbox の状況

- 未処理アイテム数: N件
- 今週追加: N件
- 今週トリアージ: N件

## 今週の意思決定

対象週に作成された Decision ファイルを一覧表示。

- [domain] 決定タイトル — YYYY-MM-DD

## 開発活動（git）

- コミット数: N
- 変更ファイル: N
- 追加/削除: +N / -N
- ブランチ: branch-1, branch-2

## 良かったこと

収集した情報から推察される、うまくいった点を記述。

## 改善したいこと

未完了タスクの傾向、Inbox の滞留、繰り返しパターンから改善点を提案。

## 学び

Knowledge/ に追加された新しい知見があれば記載。

## AI 活用（prompt-review データがある場合のみ）

対象週に `/prompt-review` で生成されたレポートがある場合、その要約を記載:
- プロンプト品質スコア
- 主な改善ポイント

## 来週の目標

- [ ] 進行中タスクのうち優先度が高いもの Top 3
- [ ] 未トリアージの Inbox アイテムの処理
- [ ] （改善したいことから導出されるアクション）
```

## 出力

ファイル作成後、以下を通知:
- 作成されたファイルパス
- KPI サマリー（完了タスク数、完了率、Inbox 未処理数）
- 前週比較があればトレンドコメント

**重要**: すべての出力は日本語で行うこと。
