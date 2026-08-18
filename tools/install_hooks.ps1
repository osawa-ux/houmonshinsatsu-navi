# pre-commit / pre-push hook をインストール
#
# 2026-08-18 修正（重大）: 共有 guard wrapper を無条件上書きしないようにした。
#   旧実装は Copy-Item -Force で .git\hooks\pre-commit / pre-push をそのまま潰していた。
#   そのため install-pre-push-guard.ps1 が設置する PUSH-GUARD-WRAPPER-V2（および
#   install-pre-commit-guard.ps1 の COMMIT-GUARD-WRAPPER-V1）が消え、guard が無言で
#   不発になっていた。実測: 本 repo で 2026-08-05〜08-17 の 12 日間 guard 未起動。
#   ロジックは tools/install_hooks.sh と同一に保つこと（片方だけ直すともう片方で壊れる）。
$ErrorActionPreference = "Stop"

# コンソール出力の文字化け防止（日本語メッセージを含むため。
# claude-memory/scripts/install-pre-push-guard.ps1 と同じ扱い）
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {
    # 一部のホスト（非対話的 pipe 等）では設定できないが致命的ではない
}

$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$HooksDir = Join-Path $RepoRoot ".git\hooks"

# 共有 guard wrapper の判定（版に依存させない）
$WrapperMarkerRe = '(PUSH|COMMIT)-GUARD-WRAPPER-V|MINIMAL-PRE-PUSH-WRAPPER'

function Install-RepoHook {
    param(
        [Parameter(Mandatory = $true)][string]$HookName,
        [Parameter(Mandatory = $true)][string]$SourceName
    )

    $src = Join-Path $RepoRoot "tools\hooks\$SourceName"
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Warning "[install] SKIP: source が見つかりません: $src"
        return
    }

    if (-not (Test-Path -LiteralPath $HooksDir)) {
        New-Item -ItemType Directory -Path $HooksDir -Force | Out-Null
    }

    $target = Join-Path $HooksDir $HookName
    $dest = $target
    $mode = "direct"

    # .git\hooks\<hook> が chain 型 wrapper なら wrapper は触らず <hook>.local へ設置する
    if (Test-Path -LiteralPath $target) {
        $existing = Get-Content -LiteralPath $target -Raw -ErrorAction SilentlyContinue
        if ($null -ne $existing -and
            ($existing -match $WrapperMarkerRe -or $existing -like "*$HookName.local*")) {
            $dest = Join-Path $HooksDir "$HookName.local"
            $mode = "chained"
        }
    }

    if ((Test-Path -LiteralPath $dest) -and $env:INSTALL_HOOKS_FORCE -ne "1") {
        $a = (Get-Content -LiteralPath $dest -Raw -ErrorAction SilentlyContinue) -replace "`r`n", "`n"
        $b = (Get-Content -LiteralPath $src  -Raw -ErrorAction SilentlyContinue) -replace "`r`n", "`n"
        if ($a -eq $b) {
            Write-Host "[install] $HookName : 既に最新（$mode）: $dest"
            return
        }
        Write-Warning "[install] $dest は source と内容が異なるため上書きしませんでした。"
        Write-Warning "[install]   source : $src"
        Write-Warning "[install]   差分   : git diff --no-index `"$dest`" `"$src`""
        Write-Warning "[install]   上書き : `$env:INSTALL_HOOKS_FORCE=1 して再実行"
        return
    }

    Copy-Item -LiteralPath $src -Destination $dest -Force
    Write-Host "[install] $HookName hook installed ($mode): $dest"
    if ($mode -eq "chained") {
        Write-Host "[install]   共有 guard wrapper ($target) は温存しました。"
    }
}

Install-RepoHook -HookName "pre-commit" -SourceName "pre-commit"
Install-RepoHook -HookName "pre-push"   -SourceName "pre-push"
