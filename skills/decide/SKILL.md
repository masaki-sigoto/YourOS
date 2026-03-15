---
name: decide
description: >
  意思決定を記録する。決定事項、理由、フォローアップを構造化し、
  重複チェック・プロジェクト紐付け・分類に対応する。
allowed-tools: Read, Write, Bash, Grep, Glob
context: fork
---

# decide スキル

意思決定を `/Users/apple/YourOS/Decisions/YYYY/YYYY-MM-DD--slug.md` に記録する。

## 引数の処理

`$ARGUMENTS` を解析:

- メインテキスト → 決定のタイトル（必須）
- `why:` 以降のテキスト → 決定理由（任意）
- `follow:` 以降のテキスト → フォローアップアクション（任意）
- `p:<project>` → 関連プロジェクト（任意）
- `domain:<kind>` → 分類（任意。`architecture` / `process` / `tooling` / `business`。デフォルト: 未分類）
- `overrides:<slug>` → 上書きする過去の Decision の slug（任意）

例:
- `/decide TypeScriptに統一する why:型安全性とDX向上 follow:既存JSファイルの段階的移行計画を作成`
- `/decide 認証にJWTを採用 p:customer-portal domain:architecture why:ステートレスでスケールしやすい`
- `/decide フレームワークをRemixに変更 overrides:adopt-nextjs why:App Routerが不安定`

引数バリデーション:

- タイトルが空の場合 → 「決定内容を指定してください。例: `/decide フレームワークをNext.jsに決定 why:理由`」と通知して終了

## slug 生成

タイトルから slug を生成:
- 英語の場合: スペースをハイフンに変換、小文字化、英数字とハイフンのみ保持
- 日本語の場合: 内容を要約した短い英語 slug を生成
- 先頭・末尾のハイフンは除去、最大30文字

## 処理フロー

### ステップ1: 重複・矛盾チェック

1. Grep で `/Users/apple/YourOS/Decisions/` 内をタイトルのキーワードで検索
2. 類似する Decision が見つかった場合:

```
類似する Decision が見つかりました:

1. 「フレームワークはNext.jsを採用する」 — 2026-03-15
   → Decisions/2026/2026-03-15--adopt-nextjs.md

この決定を上書き（override）しますか？ それとも新しい独立した決定として記録しますか？
```

3. ユーザーが override を選択した場合、`overrides:` を自動設定

### ステップ2: overrides チェーンの表示

`overrides:` が設定されている場合、元の Decision を Read で読み込み、変遷を表示:

```
Decision の変遷:
[2026-03-15] フレームワークはNext.jsを採用する
  ↓ 今回の決定で上書き
[2026-03-20] フレームワークをRemixに変更
```

### ステップ3: ファイル生成

1. `/Users/apple/YourOS/Decisions/YYYY/` が存在しない場合は作成（Bash で `mkdir -p`）
2. 同名ファイルが既にある場合は slug にサフィックス `-2`, `-3` を付与
3. 以下のテンプレートでファイルを作成

## テンプレート

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: decision
status: decided
domain: architecture / process / tooling / business / (未分類)
project: <project>（指定時のみ）
overrides: "YYYY-MM-DD--previous-slug"（指定時のみ）
tags: [t:decision]
---

# 決定: タイトル

## 決定事項

タイトルの内容をここに記載。

## 理由

`why:` の内容をここに記載。指定がない場合は「（理由を後日追記）」と記載。

## 代替案

- （検討した代替案があれば記載）

## フォローアップ

- [ ] `follow:` の内容をここに記載。指定がない場合は省略。

## 関連情報（自動検出時のみ）

- 関連プロジェクト: [project-name](Projects/project-name/)
- 上書き元: [過去の決定タイトル](Decisions/YYYY/YYYY-MM-DD--slug.md)
```

## 重要ルール

- Decisions は不変（immutable）。一度作成したら編集しない。
- 決定を覆す場合は新しい Decision ファイルを作成し、frontmatter に `overrides: YYYY-MM-DD--previous-slug` を追加する。

## 出力

ファイル作成後、以下を通知:
- 作成されたファイルパス
- 分類（domain）
- 関連プロジェクト（指定時）
- 上書き元（overrides 指定時）
- 「決定を記録しました。この決定は不変です。覆す場合は新しい `/decide` で `overrides:` を指定してください。」

**重要**: すべての出力は日本語で行うこと。
