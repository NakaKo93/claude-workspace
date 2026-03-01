# ~/.claude

Claude Code のパーソナル設定ワークスペース。
Skills の作成・メンテナンスと、ドキュメントの整理が主な用途。

## リポジトリ構成

```
~/.claude/
├── README.md               # このファイル
├── .gitignore              # Git 除外設定
├── settings.json           # Claude Code 設定
├── statusline.sh           # ステータスライン スクリプト
├── package.json            # npm 依存関係（Prettier 等）
├── hooks/                  # カスタムフック スクリプト
│   ├── block-dangerous.sh  # 危険コマンドのブロック
│   ├── force-skill-eval.sh # スキル評価の強制
│   └── play_sound.sh       # 通知音
├── commands/               # カスタムスラッシュコマンド
│   └── commit.md           # /commit コマンド
├── skills/                 # ユーザーレベルの Skills（全プロジェクトで利用可能）
│   ├── create-skill/       # スキル作成支援
│   ├── gh-pr/              # GitHub PR 作成
│   ├── git-branch/         # Git ブランチ管理
│   ├── git-commit/         # Git コミット分割
│   ├── plain-doc/          # ドキュメント生成
│   ├── reflect/            # セッション振り返り
│   └── validate-skill/     # スキル検証
└── agents/                 # カスタムサブエージェント
```

## セットアップ

### 必要なランタイム

| ランタイム | 用途                                       |
| ---------- | ------------------------------------------ |
| Node.js    | Prettier（コードフォーマット）             |
| Python 3   | Skills のスクリプト（`skills/*/scripts/`） |

### Node.js パッケージのインストール

```bash
npm install
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

