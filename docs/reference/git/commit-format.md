# Conventional Commitフォーマットリファレンス

## フォーマット

```
<type>(<scope>): <subject>
```

- コミットメッセージはすべて**英語**で記述する
- `<scope>` は省略可能

## type

| タイプ | 説明 |
|---|---|
| `feat` | 新機能の追加 |
| `fix` | バグ修正 |
| `docs` | ドキュメントのみの変更 |
| `style` | 動作に影響しないフォーマット/スタイルの変更 |
| `refactor` | 動作変更を伴わない内部コードの変更 |
| `perf` | パフォーマンス改善 |
| `test` | テストの追加または修正 |
| `chore` | ビルド・ツール・依存関係の変更 |

## scope

- ファイル名ではなく**モジュールまたはコンポーネント名**を使用する（拡張子は省略）
- 同じモジュールに属する複数ファイルは、そのモジュール名を単一のスコープとして使用する
  - 例: `auth.py` + `auth_utils.py` → スコープは `auth`
- 1つのディレクトリ内の複数ファイルにまたがる場合はディレクトリ名を使用する
- コードベース全体にまたがる広範な変更では省略する

## subject

- 命令形（例: `correct redirect handling`。`corrected` や `corrects` は不可）
- 最大30文字程度を目安にする
- 先頭の単語のみ大文字にする
- 末尾にピリオドを付けない

**30文字を超える場合は以下のパターンで短縮する:**

| テクニック | 変更前 | 変更後 |
|---|---|---|
| 冠詞/前置詞を省く | `fix error in payment module` | `fix payment error` |
| 動詞を短縮 | `implement validation logic` | `add input validation` |
| 対象を抽象化 | `fix null pointer exception in user service` | `fix NPE in user service` |

## 破壊的変更

後方互換性を壊す変更の場合、typeの後（scopeがある場合はscopeの後）に `!` を付ける:

```
feat!: remove legacy auth endpoint
feat(api)!: change response format to JSON
```

## 例

```
feat(auth): add OAuth2 login support
fix(api): correct redirect handling
docs(readme): update setup section
style(format): apply ESLint fixes
refactor(db): extract query builder
perf(cache): reduce memory allocation
test(user): add registration edge cases
chore(deps): upgrade eslint to v9
```
