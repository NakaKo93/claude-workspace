# Claude Code Statusline 表示仕様

## 1. 概要

本 statusline は Claude Code セッションの状態をリアルタイムで可視化するための表示である。
主に以下の観点を監視する。

* コンテキストウィンドウ使用率
* 1ターンあたりのトークン使用量
* キャッシュ利用効率
* トークンコスト効率
* セッション全体の進捗

---

# 2. 表示レイアウト

```
[{model}] | {branch}
📁 {filePath}
{context_bar} {used_percentage} ({remaining_tokens} left) | {alert}
ΔIN {delta_input} | ΔOUT {delta_output} | cache {cache_hit_ratio}
🚀 {usd_per_1k_tokens} | 📈 {lines_changed} ({lines_per_1k_tokens})
```

---

# 3. 各表示項目の意味

## 3.1 Model

```
[{model}]
```

### 内容

現在使用している Claude モデル名。

### 例

```
[Sonnet 4.6]
```

### 用途

* モデル切替の確認
* セッション環境の識別

---

## 3.2 Git Branch

```
| {branch}
```

### 内容

現在の Git ブランチ名。

### 用途

* 作業対象の識別
* PR / feature / hotfix の確認

---

## 3.3 Current Directory（任意表示）

```
📁 {filePath}
```

### 内容

現在の作業ディレクトリ（basename）。

### 用途

* 複数 workspace 使用時の識別

### 備考

設定により非表示にできる。

---

# 4. Context Window 表示

```
{context_bar} {used_percentage} ({remaining_tokens} left)
```

## 4.1 context_bar

例

```
####------
```

### 内容

コンテキスト使用率を10段階のバーで表示する。

### 算出

```
filled = used_percentage / 10
```

---

## 4.2 used_percentage

例

```
18%
```

### 内容

コンテキストウィンドウの使用率。

### 算出

```
used_percentage = context_window_used_tokens / context_window_size
```

---

## 4.3 remaining_tokens

例

```
164k left
```

### 内容

コンテキストウィンドウの残りトークン数。

### 算出

```
remaining_tokens = context_window_size - used_tokens
```

---

## 4.4 色表示と推奨アクション

Context 使用率に応じて表示色が変化する。
同時に、コンテキスト管理のための推奨アクションを示す。

| 使用率    | 色 | 状態 | 推奨アクション                   |
| ------ | - | -- | ------------------------- |
| 0–59%  | 緑 | 安全 | 特に対応不要                    |
| 60–74% | 黄 | 注意 | 必要に応じて `/compact` を実行     |
| 75%以上  | 赤 | 危険 | `/compact` または `/new` を実行 |

---

## 4.5 `/compact` と `/new` の使い分け

### `/compact`

会話履歴を要約し、コンテキストサイズを縮小する。

特徴

* 会話の文脈を保持
* token 使用量を削減
* セッションを継続可能

使用タイミング

```
context > 60%
```

---

### `/new`

新しいセッションを開始する。

特徴

* コンテキストを完全にリセット
* 最も確実にコンテキストを削減

使用タイミング

```
context > 75%
または
context overflow
```

---

## 4.6 運用指針

通常の作業では以下を推奨する。

```
60% 到達 → /compact 検討
75% 到達 → /compact 実行
85% 以上 → /new 推奨
```

---

# 5. Context Alert

```
| ⚠ exceeds 200k
```

### 内容

コンテキストウィンドウ上限を超えた場合の警告。

### 条件

```
exceeds_200k_tokens = true
```

### 意味

* コンテキストが上限を超過
* 古い履歴が削除されている可能性あり

---

# 6. ΔIN（入力トークン）

```
ΔIN {value}
```

例

```
ΔIN 36.2k
```

### 内容

今回ターンでモデルに送信された実効入力トークン量。

### 算出

```
ΔIN =
input_tokens
+ cache_creation_input_tokens
+ cache_read_input_tokens
```

### 意味

Claude に渡されたコンテキスト総量。

### 解釈

| 値      | 意味           |
| ------ | ------------ |
| < 1k   | 通常会話         |
| 1k〜5k  | 軽いコンテキスト     |
| 5k〜10k | ファイル読み込み     |
| >10k   | 大量コンテキスト（注意） |

---

# 7. ΔOUT（出力トークン）

```
ΔOUT {value}
```

例

```
ΔOUT 0.2k
```

### 内容

Claude が生成した出力トークン量。

### 解釈

| 値        | 意味      |
| -------- | ------- |
| < 500    | 短い応答    |
| 500〜1000 | 通常回答    |
| >1000    | 長文生成    |
| >2000    | 非常に長い回答 |

---

# 8. Cache Hit Ratio

```
cache {ratio}
```

例

```
cache 94%
```

### 内容

キャッシュ再利用率。

### 算出

```
cache_hit_ratio =
cache_read_input_tokens
/
ΔIN
```

### 意味

入力トークンのうちキャッシュ再利用された割合。

### 解釈

| 値      | 意味         |
| ------ | ---------- |
| >80%   | 高効率        |
| 50〜80% | 通常         |
| 20〜50% | 低効率        |
| <20%   | キャッシュ無効に近い |

---

# 9. Token Cost Efficiency

```
🚀 {usd_per_1k_tokens}
```

例

```
🚀 0.116/1k
```

### 内容

1000トークンあたりの平均コスト。

### 算出

```
usd_per_1k_tokens =
total_cost_usd
/
(total_tokens / 1000)
```

### 用途

* コスト効率の監視
* prompt caching 効果の確認

---

# 10. Progress Metrics

```
📈 {lines_changed} ({lines_per_1k_tokens})
```

例

```
📈 1588 (7.9/1k)
```

## 10.1 lines_changed

### 内容

セッション中に変更されたコード行数。

### 算出

```
lines_changed =
total_lines_added
+
total_lines_removed
```

---

## 10.2 lines_per_1k_tokens

### 内容

1000トークンあたりの変更行数。

### 算出

```
lines_per_1k_tokens =
lines_changed
/
(total_tokens / 1000)
```

### 意味

トークン消費に対する成果指標。

---

# 11. 色表示仕様

## Context 使用率

| 条件     | 色 | 意味                           |
| ------ | - | ---------------------------- |
| <60%   | 緑 | 安全                           |
| 60〜75% | 黄 | 注意（`/compact` 検討）            |
| >75%   | 赤 | 危険（`/compact` または `/new` 推奨） |

---

## ΔIN

| 条件     | 色  |
| ------ | -- |
| <5k    | 通常 |
| 5k〜10k | 黄  |
| >10k   | 赤  |

---

## ΔOUT

| 条件    | 色  |
| ----- | -- |
| <1k   | 通常 |
| 1k〜2k | 黄  |
| >2k   | 赤  |

---

## Cache Ratio

| 条件     | 色 |
| ------ | - |
| >50%   | 緑 |
| 20〜50% | 黄 |
| <20%   | 赤 |

---

# 12. 運用上の目安

理想的な状態

```
context < 40%
ΔIN < 1k
cache > 80%
```

注意状態

```
context > 60%
ΔIN > 5k
```

危険状態

```
context > 75%
ΔIN > 10k
cache < 20%
```
