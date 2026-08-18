#!/bin/bash
# pre-commit / pre-push hook をインストール
#
# 2026-08-18 修正（重大）: 共有 guard wrapper を無条件上書きしないようにした。
#   旧実装は .git/hooks/pre-commit と .git/hooks/pre-push を無条件 cp で上書きしていた。
#   そのため ~/claude-memory/scripts/install-pre-push-guard.ps1 が設置する
#   PUSH-GUARD-WRAPPER-V2（および install-pre-commit-guard.ps1 の
#   COMMIT-GUARD-WRAPPER-V1）が消え、guard が無言で不発になっていた。
#   実測: 本 repo で 2026-08-05〜08-17 の 12 日間、pre-push guard が一度も起動して
#   いなかった（当時の .git/hooks/pre-push は tools/hooks/pre-push と sha256 完全一致）。
set -u

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

# 共有 guard wrapper の判定（版に依存させない: V1/V2/V3… を同じ扱いにする）
WRAPPER_MARKER_RE='(PUSH|COMMIT)-GUARD-WRAPPER-V|MINIMAL-PRE-PUSH-WRAPPER'

# 設置先に既存ファイルがあり内容が異なるとき、既定では上書きしない。
# 上書きしたい場合のみ: INSTALL_HOOKS_FORCE=1 tools/install_hooks.sh
INSTALL_HOOKS_FORCE="${INSTALL_HOOKS_FORCE:-0}"

# install_repo_hook <hook 名> <tools/hooks 配下の source 名>
#   1. .git/hooks/<hook> が chain 型 wrapper（guard 本体 → <hook>.local を呼ぶ）なら
#      wrapper には一切触れず、repo 固有 hook を <hook>.local 側へ設置する。
#   2. wrapper が無ければ従来どおり .git/hooks/<hook> へ設置する
#      （guard 未導入の fresh clone・他 PC でも repo 固有 hook が動く）。
#   3. 設置先に別内容の既存ファイルがあれば上書きせず WARN で報告する（改行コード差は無視）。
install_repo_hook() {
  hook_name="$1"
  src="$REPO_ROOT/tools/hooks/$2"

  if [ ! -f "$src" ]; then
    echo "[install] SKIP: source が見つかりません: $src" >&2
    return 0
  fi

  mkdir -p "$HOOKS_DIR"
  target="$HOOKS_DIR/$hook_name"
  dest="$target"
  mode="direct"

  if [ -f "$target" ] \
     && { grep -qE "$WRAPPER_MARKER_RE" "$target" 2>/dev/null \
          || grep -qF "$hook_name.local" "$target" 2>/dev/null; }; then
    dest="$HOOKS_DIR/$hook_name.local"
    mode="chained"
  fi

  if [ -f "$dest" ] && [ "$INSTALL_HOOKS_FORCE" != "1" ]; then
    if [ "$(tr -d '\r' < "$dest")" = "$(tr -d '\r' < "$src")" ]; then
      chmod +x "$dest" 2>/dev/null || true
      echo "[install] $hook_name: 既に最新（$mode）: $dest"
      return 0
    fi
    echo "[install] WARN: $dest は source と内容が異なるため上書きしませんでした。" >&2
    echo "[install]   source : $src" >&2
    echo "[install]   差分   : diff \"$dest\" \"$src\"" >&2
    echo "[install]   上書き : INSTALL_HOOKS_FORCE=1 tools/install_hooks.sh" >&2
    return 0
  fi

  cp "$src" "$dest"
  chmod +x "$dest"
  echo "[install] $hook_name hook installed ($mode): $dest"
  if [ "$mode" = "chained" ]; then
    echo "[install]   共有 guard wrapper ($target) は温存しました。"
  fi
}

install_repo_hook pre-commit pre-commit
install_repo_hook pre-push   pre-push
