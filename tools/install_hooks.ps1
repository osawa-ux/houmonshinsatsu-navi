# pre-commit hook をインストール
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Copy-Item "$RepoRoot\tools\hooks\pre-commit" "$RepoRoot\.git\hooks\pre-commit" -Force
Write-Host "pre-commit hook installed: $RepoRoot\.git\hooks\pre-commit"
