#!/bin/bash
# pre-commit / pre-push hook をインストール
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cp "$REPO_ROOT/tools/hooks/pre-commit" "$REPO_ROOT/.git/hooks/pre-commit"
chmod +x "$REPO_ROOT/.git/hooks/pre-commit"
echo "[install] pre-commit hook installed: $REPO_ROOT/.git/hooks/pre-commit"

cp "$REPO_ROOT/tools/hooks/pre-push" "$REPO_ROOT/.git/hooks/pre-push"
chmod +x "$REPO_ROOT/.git/hooks/pre-push"
echo "[install] pre-push hook installed: $REPO_ROOT/.git/hooks/pre-push"
