---
name: triage
description: >
  YourOS Inboxのアイテムを読み取り、適切な場所（Projects/Knowledge/SOP/Decisions/Scratch）へ
  昇格（promote）する。AIコンテキスト提案と一括モードに対応。
allowed-tools: Read, Write, Bash, Grep, Glob
context: fork
---

# triage スキル

YourOS Inbox のアイテムを読み取り、ユーザーと対話しながら適切な場所に仕分ける。

## 引数の処理

`$ARGUMENTS` を解析:

- `today` または引数なし → 今日の日付 (`/Users/apple/YourOS/Inbox/YYYY/YYYY-MM-DD.md`)
- `YYYY-MM-DD` → 指定日付のファイル
- `all` → `/Users/apple/YourOS/Inbox/` 配下の全ファイルをスキャン（Glob で `**/*.md` を検索）
- `--auto` → 一括提案モード（後述）

## 処理フロー

### ステップ1: アイテムの抽出

1. 対象の Inbox ファイルを Read で読み込む
2. `## キャプチャ` セクション内の各アイテム（`- **HH:MM** | 内容`）を抽出
3. 取り消し線（`~~`）や「昇格済み」「破棄」マーク付きのアイテムは除外
4. 未処理アイテムが0件の場合は「Inbox に未処理のアイテムがありません。」と通知して終了

### ステップ2: コンテキスト収集（提案精度の向上）

仕分け提案の前に、以下の既存情報を収集して提案の精度を高める:

1. **既存プロジェクト一覧**: Glob で `/Users/apple/YourOS/Projects/*/` のフォルダ名を取得
2. **アクティブタスク**: 各プロジェクトの active タスクのタイトルを取得（上位5件）
3. **Inbox 内のタグ**: `[p:project]` タグが付いているアイテムのプロジェクト名を抽出

この情報を使って、アイテムが既存プロジェクトに関連するかどうかを判断する。

### ステップ3: 仕分け（対話モード / 一括モード）

#### 対話モード（デフォルト）

各アイテムについて仕分け先を提案:

```
N件の未処理アイテムがあります。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. "ホームページのデザインを変えたい"

   → 提案: Projects/homepage-renewal に追加
     （理由: 既存プロジェクト「homepage-renewal」に3件のアクティブタスクがあり、関連性が高い）

   どこに入れますか？
   - Projects（プロジェクトのタスクとして管理）
   - Knowledge（知識として記録）
   - SOP（手順書として記録）
   - Decisions（決定事項として記録）
   - Prompts（プロンプト雛形として保存）
   - Scratch（一時的な作業メモ）
   - Skip（今はまだ整理しない、Inbox に残す）
   - Discard（いらない、破棄する）
```

#### 一括提案モード（`--auto`）

全アイテムの提案を一覧表示し、ユーザーは修正だけ行う:

```
一括提案モード: 以下の仕分けを提案します。

1. "ホームページのデザインを変えたい" → Projects/homepage-renewal
2. "React と Vue どっちがいいか調べる" → Knowledge/dev
3. "山田さんから聞いたセキュリティの話" → Knowledge/biz
4. "デプロイ手順を書く" → SOP/ops

修正が必要な番号を入力してください（例: 「2 → Skip」）。
「OK」で全て確定します。
```

### ステップ4: 仕分け提案のロジック

#### キーワードマッチ（第1段階）

| キーワード | 提案先 |
| ---------- | ------ |
| プロジェクト、実装、機能、タスク、作る、開発 | Projects |
| 学んだ、メモ、知見、TIL、調べる、比較 | Knowledge |
| 手順、やり方、セットアップ、インストール、設定 | SOP |
| 決定、決めた、方針、採用、やめる | Decisions |
| プロンプト、テンプレ、定型、雛形 | Prompts |
| 一時、仮、実験、試す、検証 | Scratch |

#### コンテキストマッチ（第2段階）

- `[p:project]` タグが付いている → 該当 Projects に優先提案
- アイテム内容が既存プロジェクト名やタスクタイトルと部分一致 → 該当 Projects に提案し、理由を表示
- 緊急マーク（🔴）付き → Projects のタスクとして高優先度を提案

提案はあくまで候補であり、ユーザーの判断を優先する。

### ステップ5: 昇格処理

ユーザーの選択に従い、Write でファイルを作成・追記する。

#### 各昇格先のテンプレート

**Projects 昇格時**: プロジェクト名を確認し、`/Users/apple/YourOS/Projects/<project>/Tasks/` または `/Notes/` にファイルを作成。

**Knowledge 昇格時**: サブフォルダ（dev/biz/tools）を確認し記録。

**SOP 昇格時**: サブフォルダ（dev/ops/security）を確認し記録。

**Decisions 昇格時**: 以下の frontmatter を使用:

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: decision
status: decided
tags: []
---

# 決定: タイトル

## 背景

(Inbox アイテムの内容を展開)

## 決定事項

(ユーザーの入力に基づく)

## 理由

(ユーザーの入力に基づく)
```

**Scratch 昇格時**: `/Users/apple/YourOS/Scratch/Daily/YYYY-MM-DD--slug.md` に作成。

**Discard**: Archive/ は AI 読み取り専用のため書き込まない。Inbox 内で取り消し線を付けて破棄（`~~内容~~ → 破棄`）。

### ステップ6: 元ファイルの更新

昇格したアイテムは元の Inbox ファイルで `- ~~**HH:MM** | 内容~~ → 昇格済み (行き先)` と取り消し線で更新。

## 出力

トリアージ完了後、仕分け結果のサマリーを表示:

```
整理完了:
- プロジェクトに昇格: N件
- ナレッジに記録: N件
- SOPに追加: N件
- Scratchに移動: N件
- スキップ（Inbox残留）: N件
- 破棄: N件
```

**重要**: すべての出力は日本語で行うこと。仕分け提案や対話もすべて日本語で行う。
