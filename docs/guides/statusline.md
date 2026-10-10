# Claude Code Statusline 表示仕様

## 1. 概要

本 statusline は Claude Code セッションの状態をリアルタイムで可視化するための表示である。
主に以下の観点を監視する。

* 作業場所（ブランチ・ディレクトリ）
* コンテキストウィンドウ使用率
* 利用制限（5時間・週次）の使用率と回復時刻

---

# 2. 表示レイアウト

```
💬 {session_name}
[{model}] | {branch} ({sub_dir})
🔋 {context_bar} {used_percentage} ({remaining_tokens} left) | {alert}
🕔 {five_hour_bar} {five_hour_pct} ({HH:MM}) | 📅 {seven_day_bar} {seven_day_pct} ({MM/DD HH:MM})
```

例

```
💬 statusline見直し
[Opus] | main (docs/guides/)
🔋 #######--- 78% (220.0k left) | ⚠ /compact推奨
🕔 #---- 24% (19:00) | 📅 ####- 81% (10/14 09:00)
```

---

# 3. Session Name / Model / 作業場所

## 3.1 Model

```
[{model}]
```

現在使用している Claude モデル名。モデル切替の確認に使う。

## 3.2 Session Name

```
💬 {session_name}
```

現在のセッション（スレッド）名（`session_name`）。

* `/rename` または `--name` で付けた名前を表示する
* 未設定の場合は AI が自動生成したタイトルを表示する
* 長い名前でも他の表示を圧迫しないよう、独立した行（最上段）に表示する
* どちらもない場合（セッション開始直後など）は表示しない

## 3.3 Branch と現在ディレクトリ

```
{branch} ({sub_dir})
```

### 内容

* `branch`：現在の Git ブランチ名
* `sub_dir`：リポジトリルートから現在の作業ディレクトリまでのパス（`git rev-parse --show-prefix`）

### 備考

* リポジトリルートにいる場合はルートのフォルダ名を表示する（例：`main (.claude/)`）
* Git リポジトリ外ではブランチ・パスとも表示しない

---

# 4. Context Window

```
🔋 {context_bar} {used_percentage} ({remaining_tokens} left) | {alert}
```

## 4.1 context_bar

使用率を10段階のバーで表示する（`filled = used_percentage / 10`）。

```
####------
```

## 4.2 used_percentage

コンテキストウィンドウの使用率（`context_window.used_percentage`）。
ウィンドウサイズ（200k / 1M）に依存しない割合で判断する。

## 4.3 remaining_tokens

```
remaining_tokens = context_window_size × (1 − used_percentage / 100)
```

通常は既定色で表示し、使用率 75% 以上（残り少）のときのみ赤で表示する。

## 4.4 alert

使用率が 75% 以上のとき `⚠ /compact推奨` を表示する。
固定値（200k 超過）ではなく割合で判定するため、1M ウィンドウでも同じ基準で機能する。

## 4.5 色表示と推奨アクション

| 使用率    | 色 | 状態 | 推奨アクション                   |
| ------ | - | -- | ------------------------- |
| 0–59%  | 緑 | 安全 | 特に対応不要                    |
| 60–74% | 黄 | 注意 | 必要に応じて `/compact` を実行     |
| 75%以上  | 赤 | 危険 | `/compact` または `/new` を実行 |

## 4.6 `/compact` と `/new` の使い分け

* `/compact`：会話履歴を要約してコンテキストを縮小する。文脈を保ったまま継続できる
* `/new`：新しいセッションを開始する。コンテキストを完全にリセットする

運用指針

```
60% 到達 → /compact 検討
75% 到達 → /compact 実行
85% 以上 → /new 推奨
```

---

# 5. 利用制限（Rate Limits）

```
🕔 {five_hour_bar} {five_hour_pct} ({HH:MM}) | 📅 {seven_day_bar} {seven_day_pct} ({MM/DD HH:MM})
```

## 5.1 内容

| 表示 | 意味 | 元データ |
| -- | -- | -- |
| `🕔` | 5時間ごとのセッション制限 | `rate_limits.five_hour.used_percentage` |
| `📅` | 週次制限 | `rate_limits.seven_day.used_percentage` |
| バー | 使用率を5段階で表示（`filled = used_percentage / 20`） | 同上 |
| 日時 | 制限が回復（リセット）する時刻（ローカル時刻） | `rate_limits.*.resets_at`（Unix epoch 秒） |

5時間制限は時刻（`HH:MM`）、週次制限は日付付き（`MM/DD HH:MM`）で表示する。

## 5.2 表示条件

* claude.ai の Pro / Max 契約時のみ、かつ最初の API 応答後に表示される
* API キー利用時や、セッション開始直後は3行目自体を表示しない
* 各制限は個別に省略されることがある（リセット時刻を過ぎた制限は消える）

## 5.3 色表示

| 使用率    | 色 |
| ------ | - |
| <60%   | 緑 |
| 60〜79% | 黄 |
| 80%以上  | 赤 |

---

# 6. 運用上の目安

理想的な状態

```
context < 40%
5h / 7d < 60%
```

注意状態

```
context > 60%
5h / 7d > 60%
```

危険状態

```
context > 75%
5h / 7d > 80%（回復時刻を確認して作業量を調整）
```
