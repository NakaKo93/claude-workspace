# ts-git-branch

**何をするか**: 規約に沿ったブランチを作成・削除する。
未コミット変更がある場合は `git stash` で退避してから移動する。

**起動フレーズ**: `ブランチを切って` / `新しいブランチを作って` / `マージしたブランチを削除して`

---

## ブランチ名の形式

```
<type>/<scope>/<short-slug>
# または
<type>/<short-slug>
```

- **type**: `feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `chore`
- **scope**: ディレクトリ名・モジュール名（スコープが広い場合は省略）
- **slug**: kebab-case・小文字・2〜5語の命令形（例: `add-compact-warning`）

## ブランチ作成フロー

1. 作業内容からブランチ名を提案
2. 未コミット変更の有無を確認
3. 確認画面を提示 → `yes` で実行（stash が必要な場合は自動でステップに含める）

```
Base:   main
New:    feat/statusline/add-compact-warning

Create this branch? [yes / edit / cancel]
```

## マージ済みブランチの削除

`git branch --merged main` でリストアップし、確認後に `-d` で削除。
未マージコミットがある場合は `-d` が失敗する（意図的）。

## ライフサイクル

- **最大存続期間**: 1〜2 日（マージ後は即削除）
- **ベースブランチ**: 常に `main` から切る
- **1ブランチ = 1目的**（複数の無関係な修正を混在させない）
