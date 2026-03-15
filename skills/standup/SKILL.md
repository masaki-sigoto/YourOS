---
name: standup
description: >
  日次スタンドアップ形式で状況を表示する。昨日の完了・今日の予定・ブロッカーを
  自動収集してまとめる。/nextの拡張版。
allowed-tools: Read, Grep, Glob, Bash
context: fork
---

# standup スキル

昨日の完了タスク、今日の予定、ブロッカーを自動収集し、日次スタンドアップ形式で表示する。読み取り専用。

## 引数の処理

`$ARGUMENTS` を解析:

- `p:<project>` → 特定プロジェクトに限定（任意）
- 引数なし → 全プロジェクト横断

## 処理フロー

### ステップ1: 昨日の活動を収集

1. 昨日の日付を計算（週末の場合は直近の平日）
2. 以下をスキャン:
   - **完了タスク**: Glob で `Projects/*/Tasks/*.md` を検索し、`updated:` が昨日で `status: done` のタスク
   - **Inbox 追加**: `/Users/apple/YourOS/Inbox/YYYY/YYYY-MM-DD.md`（昨日の日付）のキャプチャ件数
   - **Decision**: `Decisions/YYYY/` 配下で昨日作成されたファイル
   - **Spec**: `Projects/*/Specs/` 配下で昨日作成・更新されたファイル
   - **git コミット**: `git log --since="yesterday" --until="today" --oneline`（実行ディレクトリにgitがある場合のみ）

### ステップ2: 今日の予定を生成

1. `/next` と同じロジックでアクティブタスクをスキャンし、Top 3 を取得
2. 期限超過タスクを別途抽出
3. 最新の Handoff メモ（過去3日以内）があれば中断箇所を取得

### ステップ3: ブロッカーの検出

以下のシグナルからブロッカーを推定:

- 期限超過が3日以上のタスク → 「長期停滞タスクあり」
- Handoff メモの「未解決の問題」セクションに内容がある → ブロッカーとして表示
- 未処理 Inbox が10件以上 → 「Inbox 整理が必要」

## 出力フォーマット

```
## 📋 デイリースタンドアップ — YYYY-MM-DD（曜日）

### ✅ 昨日やったこと

- [完了] タスクタイトル (p:project-name)
- [Decision] フレームワークをNext.jsに決定
- [Spec] ログイン画面の設計を作成
- git: 5コミット (feature/login-screen ブランチ)

（何もない場合: 「昨日の活動記録はありません」）

### 📌 今日やること

1. [高] タスクタイトル (p:project-name, 期限:YYYY-MM-DD)
2. [通常] タスクタイトル (p:project-name)
3. [通常] タスクタイトル (p:project-name)

（引き継ぎメモがある場合）
> 前回の中断: 中断箇所の内容

### 🚧 ブロッカー

- ⚠ 「OAuth実装」が5日間停滞中 (p:customer-portal)
- ⚠ Handoff未解決: 「外部APIのレート制限に要対応」
- ⚠ 未処理 Inbox: 12件 → `/triage` を推奨

（ブロッカーなしの場合: 「ブロッカーなし 👍」）

---
📊 全体: active タスク N件 / 期限超過 N件 / 未処理 Inbox N件
```

**重要**: すべての出力は日本語で行うこと。
