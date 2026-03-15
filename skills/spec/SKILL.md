---
name: spec
description: >
  プロジェクトの仕様書を作成する。受入条件の自動生成・依存関係・Spec種別に対応し、
  既存のDecisions/Knowledgeを参照して精度の高い設計書を生成する。
allowed-tools: Read, Write, Bash, Grep, Glob
context: fork
---

# spec スキル

プロジェクトの仕様書を `/Users/apple/YourOS/Projects/<project>/Specs/YYYY-MM-DD--slug.md` に作成する。

## 引数の処理

`$ARGUMENTS` を解析:

- `p:<project>` → プロジェクト名（必須）
- `type:<kind>` → Spec 種別（任意。`feature` / `bugfix` / `refactor` / `research`。デフォルト: `feature`）
- `depends:p:<other-project>` → 依存するプロジェクト（任意。複数指定可）
- 残りの文字列 → 仕様の説明（slug 生成に使用）

例:
- `/spec p:customer-portal ログイン画面のリデザイン`
- `/spec p:customer-portal type:bugfix ログインエラー時のリダイレクト修正`
- `/spec p:api-server type:refactor 認証ミドルウェアの整理 depends:p:customer-portal`

引数バリデーション:

- `p:` が省略された場合 → 「プロジェクト名を指定してください。例: `/spec p:my-project 機能の説明`」と通知して終了
- 説明が空の場合 → 「仕様の説明を指定してください」と通知して終了

## slug 生成

説明文から slug を生成:
- 英語の場合: スペースをハイフンに変換、小文字化、英数字とハイフンのみ保持
- 日本語の場合: 内容を要約した短い英語 slug を生成（例: 「ログイン画面」→ `login-screen`）
- 先頭・末尾のハイフンは除去
- 最大30文字

## 処理フロー

### ステップ1: プロジェクトフォルダの準備

1. `/Users/apple/YourOS/Projects/<project>/` が存在しない場合:
   - `/Users/apple/YourOS/Projects/<project>/Context/`, `Specs/`, `Tasks/`, `Notes/`, `Links/` を `mkdir -p` で作成
   - `/Users/apple/YourOS/Projects/_index.md` を Read で読み込み、テーブル末尾に以下の行を追記:
     `| <project> | active | YYYY-MM-DD | — | — |`

### ステップ2: 関連情報の収集（受入条件の自動生成用）

仕様書の品質を高めるため、以下を事前に収集:

1. **関連 Decisions**: Grep で説明文のキーワードを `Decisions/` から検索。関連する意思決定を「背景」セクションに反映
2. **関連 Knowledge**: Grep で `Knowledge/` を検索。技術的な知見を「検証方法」や「リスク」に反映
3. **既存 Specs**: 同プロジェクトの既存 Spec を確認し、スコープの重複がないかチェック
4. **プロジェクトの Context/**: 背景情報があれば参照

### ステップ3: 仕様書の生成

`/Users/apple/YourOS/Projects/<project>/Specs/YYYY-MM-DD--slug.md` を以下のテンプレートで作成。

**説明文と収集した関連情報をもとに、受入条件を具体的に自動生成する。** プレースホルダーではなく、説明文から推測される実際の条件を3-5項目記載する。

## テンプレート

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: spec
spec-type: feature / bugfix / refactor / research
project: <project>
status: draft
depends: [p:other-project]（指定時のみ）
tags: [p:<project>, t:spec]
---

# 仕様書: タイトル（説明文から生成）

## 背景

なぜこの変更が必要か。現状の問題点やユーザーの要求を記述する。
（関連 Decision がある場合はここで言及: 「[Decision: タイトル](パス) に基づき...」）

## 目的

この仕様が達成すべきゴールを1-3文で明確に記述する。

## スコープ外

- この仕様では扱わないことを明示する

## 受入条件

（説明文から推測して具体的に記載。プレースホルダーではなく実際の条件を書く）

- [ ] 条件1: 具体的で検証可能な基準
- [ ] 条件2: 具体的で検証可能な基準
- [ ] 条件3: 具体的で検証可能な基準

## タスク分解

1. タスク1
2. タスク2
3. タスク3

## 検証方法

（type による切り替え）
- feature: ユーザーテスト、E2Eテスト
- bugfix: 再現手順での確認、回帰テスト
- refactor: 既存テストが全てパス、パフォーマンス比較
- research: 調査結果のまとめ、比較表の作成

## 依存関係（depends 指定時のみ）

- depends: p:other-project — 依存の理由

## リスク

| リスク | 影響度 | 対策 |
| ------ | ------ | ---- |
| リスク1 | 高/中/低 | 対策内容 |
```

## 出力

ファイル作成後、以下を通知:
- 作成されたファイルパス
- Spec 種別（feature/bugfix/refactor/research）
- 関連 Decision がある場合はその件数
- 「仕様書のドラフトを作成しました。内容を確認・編集してから status を active に変更してください。」

**重要**: すべての出力は日本語で行うこと。
