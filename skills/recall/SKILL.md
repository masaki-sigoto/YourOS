---
name: recall
description: >
  特定トピックに関する過去の意思決定・知見・Specを時系列で表示する。
  「なぜこうなったか」の経緯追跡に使う。
allowed-tools: Read, Grep, Glob, Bash
context: fork
---

# recall スキル

特定のトピックに関する YourOS 内の情報を時系列で集約し、経緯を追跡できる形で表示する。読み取り専用。

## 引数の処理

`$ARGUMENTS` を解析:

- メインテキスト → トピックキーワード（必須）
- `p:<project>` → 特定プロジェクトに限定（任意）

例:
- `/recall 認証` → 認証に関する全ての経緯を時系列表示
- `/recall Next.js p:homepage-renewal` → homepage-renewal プロジェクトの Next.js 関連経緯
- `/recall フレームワーク選定` → フレームワーク選定の意思決定チェーン

引数バリデーション:

- キーワードが空の場合 → 「振り返るトピックを指定してください。例: `/recall 認証方式`」と通知して終了

## 処理フロー

### ステップ1: 関連情報の収集

以下のフォルダを順に検索（Grep でキーワード検索、大文字小文字不問）:

1. **Decisions/** → 意思決定ログ（`overrides:` チェーンも追跡）
2. **Projects/*/Specs/** → 関連する設計書
3. **Knowledge/** → 関連する知見
4. **Projects/*/Tasks/** → 関連するタスク（完了・進行中とも）
5. **Inbox/** → まだ整理されていないメモ
6. **SOP/** → 関連する手順書

`p:<project>` が指定されている場合は、Projects は当該プロジェクトのみに限定。Decisions/Knowledge/SOP は全体から検索。

### ステップ2: Decision チェーンの構築

Decisions の中で `overrides:` が設定されているものを検出し、意思決定の変遷チェーンを構築する:

```
[2026-03-10] フレームワークはNext.jsを採用
  ↓ overridden by
[2026-03-20] フレームワークをRemixに変更 (理由: App Routerが不安定)
  = 現在有効な決定
```

### ステップ3: タイムライン生成

収集した情報を日付順（古い順）に並べ、以下のタイムライン形式で表示する。

## 出力フォーマット

```
「認証」に関する経緯:

━━━━ タイムライン ━━━━

📅 2026-03-10
  📋 [Decision] JWT認証を採用する
     理由: ステートレスでスケールしやすい
     → Decisions/2026/2026-03-10--adopt-jwt.md

📅 2026-03-12
  📄 [Spec] ログイン画面の設計
     受入条件: 5項目（3完了 / 2未完了）
     → Projects/customer-portal/Specs/2026-03-12--login-screen.md

📅 2026-03-14
  ✅ [Task/完了] JWTトークン生成の実装
     → Projects/customer-portal/Tasks/2026-03-14--jwt-impl.md

📅 2026-03-18
  📋 [Decision] リフレッシュトークンの有効期限を7日に設定
     理由: セキュリティとUXのバランス
     → Decisions/2026/2026-03-18--refresh-token-ttl.md

📅 2026-03-20
  🔄 [Task/進行中] OAuth2.0 Google連携の実装
     → Projects/customer-portal/Tasks/2026-03-20--oauth-google.md

━━━━ サマリー ━━━━

- 関連 Decision: 2件（全て有効、上書きなし）
- 関連 Spec: 1件（受入条件 60% 達成）
- 関連 Task: 完了1件 / 進行中1件
- 関連 Knowledge: 0件
```

ヒットが0件の場合: 「"キーワード" に関する情報は見つかりませんでした。」

**重要**: すべての出力は日本語で行うこと。
