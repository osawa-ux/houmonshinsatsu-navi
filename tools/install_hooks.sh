#!/bin/bash
# pre-commit hook をインストール
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cp "$REPO_ROOT/tools/hooks/pre-commit" "$REPO_ROOT/.git/hooks/pre-commit"
chmod +x "$REPO_ROOT/.git/hooks/pre-commit"
echo "pre-commit hook installed: $REPO_ROOT/.git/hooks/pre-commit"
