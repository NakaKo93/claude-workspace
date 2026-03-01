# ~/.claude

Claude Code のパーソナル設定ワークスペース。
Skills の作成・メンテナンスと、ドキュメントの整理が主な用途。

## ディレクトリ構成

```
~/.claude/
├── README.md               # このファイル
├── .claude/                # このディレクトリ自体の設定 (CLAUDE.md, settings)
├── skills/                 # ユーザーレベルの Skills（全プロジェクトで利用可能）
├── commands/               # カスタムスラッシュコマンド
└── agents/                 # カスタムサブエージェント
```

## セットアップ

### 必要なランタイム

| ランタイム | 用途                                       |
| ---------- | ------------------------------------------ |
| Node.js    | Prettier（コードフォーマット）             |
| Python 3   | Skills のスクリプト（`skills/*/scripts/`） |

### Node.js パッケージのインストール

このワークスペースでは [Prettier](https://prettier.io/) を Claude Code の Hooks 経由でコードフォーマットに使用しています。
プロジェクトルートで以下を実行してください。

```bash
npm install --save-dev prettier
```

### Python のインストール

Hooks および Skills のスクリプトで Python 3 を使用しています。
事前にインストールされていることを確認してください。

```bash
python --version  # Python 3.x であることを確認
```

### Prettier の役割

Prettier は Claude Code の PostToolUse Hook として設定されており、
ファイル編集後に自動でフォーマットが適用されます。
手動で実行する必要はありません。

## ルール

- **Skills ファイルは英語で記述**（SKILL.md, references/, scripts/, assets/）
