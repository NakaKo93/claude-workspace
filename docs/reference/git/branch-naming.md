# ブランチ命名フォーマット

GitHub Flow / Feature Branch Workflowの原則に基づき、Conventional Commitsの語彙に合わせた命名規則。

## 目次

- [フォーマット](#フォーマット)
- [type](#type)
- [scope](#scope)
- [short-slug](#short-slug)
- [使用可能な文字](#使用可能な文字)
- [例](#例)

---

## フォーマット

**完全形（スコープが明確な場合に推奨）:**

```
<type>/<scope>/<short-slug>
```

**短縮形（スコープが広い、またはコードベース全体にまたがる場合）:**

```
<type>/<short-slug>
```

---

## type

チームの語彙を統一するため、Conventional Commitsと同じタイプを再利用する:

| タイプ | 使用タイミング |
|---|---|
| `feat` | 新機能の追加 |
| `fix` | バグ修正 |
| `docs` | ドキュメントのみの変更 |
| `style` | 動作に影響しないフォーマット/スタイルの変更 |
| `refactor` | 動作変更を伴わない内部コードの変更 |
| `perf` | パフォーマンス改善 |
| `test` | テストの追加または修正 |
| `chore` | ビルド・ツール・依存関係の変更 |

---

## scope

- モジュールまたはコンポーネント名を使用する（コミットのスコープと同じ規則）
- 変更がコードベース全体にまたがる、または明確なモジュール境界がない場合は省略する
- 1つのディレクトリ内の複数ファイルにまたがる場合はディレクトリ名を使用する

---

## short-slug

- ケバブケース、小文字のみ
- 短くて説明的 — 2〜5語を目安にする
- 命令形が推奨（例: `add-oauth2-login`、`oauth2-login-added` ではない）
- `fix-bug` や `update-code` のような汎用的なスラッグは避ける

**説明が長すぎる場合は以下のパターンで短縮する:**

| テクニック | 変更前 | 変更後 |
|---|---|---|
| 冠詞を省く | `fix-error-in-payment-module` | `fix-payment-error` |
| 対象を抽象化 | `fix-null-pointer-in-user-service` | `fix-npe-user-service` |
| 動詞を短縮 | `implement-validation-logic` | `add-input-validation` |

---

## 使用可能な文字

| 使用可能 | `a-z`, `0-9`, `-`（ハイフン）, `/`（階層用スラッシュ） |
|---|---|
| 禁止 | スペース、`~`、`^`、`:`、`?`、`*`、`[`、`\`、`..`、`@{`、先頭/末尾の `/`、連続した `//` |

これらの制約はGitのリファレンス名ルール（`git check-ref-format`）に由来する。`a-z0-9-/` に限定することで互換性の問題をすべて回避できる。

---

## 例

```
feat/auth/add-oauth2-login
fix/api/handle-redirect-edgecase
docs/readme/update-setup-section
refactor/db/extract-query-builder
perf/cache/reduce-memory-allocation
test/user/add-registration-edge-cases
chore/deps/bump-eslint-v9
style/format/apply-eslint-fixes
feat/add-dark-mode
fix/correct-redirect-handling
```
