# pre-commit / pre-push hook をインストール
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Copy-Item "$RepoRoot\tools\hooks\pre-commit" "$RepoRoot\.git\hooks\pre-commit" -Force
Write-Host "[install] pre-commit hook installed: $RepoRoot\.git\hooks\pre-commit"

Copy-Item "$RepoRoot\tools\hooks\pre-push" "$RepoRoot\.git\hooks\pre-push" -Force
Write-Host "[install] pre-push hook installed: $RepoRoot\.git\hooks\pre-push"
