# Guides

このディレクトリはワークスペース（`~/.claude/`）固有のスキルとフックの使い方をまとめたガイドです。

プラグイン提供のスキル・フックのガイドは各プラグインの `docs/guides/` を参照してください。

---

## Skills

### 自動参照スキル（autonomous）

ユーザーが明示的に呼ばない。Claude が自律的に読み込む。

| スキル | 概要 | 参照タイミング |
|---|---|---|
| [kn-clarification-rules](skills/kn-clarification-rules.md) | 意図確認・スコープ判断ルール | 曖昧なリクエストや計画策定の前 |
| [kn-implementation-conventions](skills/kn-implementation-conventions.md) | 実装規約（ファイル命名・ツール使用制約） | ファイル操作・実装開始の前 |
| [kn-response-conventions](skills/kn-response-conventions.md) | 返答スタイル・出力フォーマット規約 | 調査結果や構造化レポートを提示する前 |

---

## Hooks

`~/.claude/hooks/` に配置されたワークスペース固有のシェルスクリプト。

| フック | イベント | マッチャー | 概要 |
|---|---|---|---|
| [play_sound](hooks/play_sound.md) | Notification / Stop | `permission_prompt` / — | 通知音を再生 |

---

## 関連ファイル

- `~/.claude/settings.json` — フック登録設定
- `plugins/` — プラグイン提供スキル・フックのガイドは各プラグインの `docs/guides/` を参照
