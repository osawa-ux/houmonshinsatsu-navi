# houmonshinsatsu-navi — pre-commit hook 運用詳細（動作仕様・誤動作パターン・CI trigger）

CLAUDE.md から 2026-07-06 に verbatim 移動（W6・行削除なし）。出典: 元 CLAUDE.md L174-L197 ＋ L209-L218（間の L198-L207 `--no-verify` 使用ルールは safety 核として CLAUDE.md に残置・本ファイルには含まない）。

---

## pre-commit hook の動作仕様

`tools/hooks/pre-commit` は **MyPython の `check_neutrality.py` への依存**を持つ。

- MyPython が配置されている PC: pre-commit hook は blog/guide 変更時に check_neutrality.py を実行し、禁止語があれば commit を中止する
- MyPython 未配置 / Windows PowerShell-only 環境: pre-commit hook は WARNING を stderr に出力した上で exit 0 する。**この場合 CI（`.github/workflows/neutrality-check.yml`）が唯一の防衛線**となる
- `--no-verify` で hook を bypass しても CI が同じ検査を実行する（二重チェック体制）

つまり「ローカル pre-commit による即時停止」は MyPython 配置 PC の **best effort** であり、信頼の根拠は **CI（GitHub Actions）** に置く設計。新 PC / clone 直後で MyPython を取得していない状態でも blog/guide の変更 commit は可能だが、CI が push 時に検査する。

- MyPython の配置 path は `$HOME/projects/MyPython` と `$HOME/MyPython` の両方を試行する
- Python コマンド動的判定: `python`（Python 3 確認）→ `python3` の順で fallback する。Windows で `python3` が MS Store リダイレクトになる問題への対応
- hook source（`tools/hooks/`）が更新された場合、各 PC で `bash tools/install_hooks.sh` または `powershell tools/install_hooks.ps1` の再実行が必要。`.git/hooks/` 配下は git 同期対象外のため自動反映されない

### 過去の誤動作パターン（debug 起点）

hook が誤動作したときは以下を順に確認する:

1. `.git/hooks/pre-commit` と `tools/hooks/pre-commit` の diff を取る（5/17 配置時から source 更新が反映されていない可能性。`bash tools/install_hooks.sh` で再配置）
2. hook 内の `python3` / `python` コマンドが Windows で MS Store リダイレクトになっていないか確認（`python -c "import sys; print(sys.executable)"` で実際の実行先を確認）
3. hook が参照する MyPython の path（`$HOME/projects/MyPython` / `$HOME/MyPython`）に check_neutrality.py が実在するか確認
4. hook 内の `2>/dev/null` が stderr を隠蔽していないか確認。デバッグ時は一時的に外して stderr を見る
5. 過去事例: 2026-06-03 に上記 1+2+4 が同時発生し「禁止語検出」誤メッセージで commit が常時 block されていた（commit `ddd9761045` で恒久解消）


### CI workflow trigger 一覧

| workflow | trigger | 役割 |
|---|---|---|
| `.github/workflows/neutrality-check.yml` | push / PR で blog/** または guide/** が変更 | 禁止語の自動検査 (CI 防衛線) |
| `.github/workflows/notion-commit-log.yml` | gh-pages branch へ push | commit を Notion DB に記録 |
| `.github/workflows/deploy-quality-log.yml` | gh-pages branch へ push | sitemap URL / clinic / pref / blog / guide HTML 数の記録 + 前回比 5% 超減少で `::warning::` |

trigger は競合しない（neutrality-check は path 変更時のみ、notion-commit-log と deploy-quality-log は同じ gh-pages push を別目的で処理）。pre-commit hook の WARNING + CI 二重防衛体制は変わらない。

