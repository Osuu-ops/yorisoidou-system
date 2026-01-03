[CmdletBinding()]
param(
  [switch]$Help,
  [switch]$DryRun,
  [Parameter()][string]$IdeaId,
  [Parameter()][string]$Ref,
  [Parameter()][string]$Desc
)

function Show-Usage {
@"
mep_idea_receipt.ps1

Purpose:
  Create one receipt line and (optionally) open a PR to append it into docs/MEP/IDEA_RECEIPTS.md.

Usage:
  .\tools\mep_idea_receipt.ps1 -Help

  # dry-run (prints the line only)
  .\tools\mep_idea_receipt.ps1 -DryRun -IdeaId <12chars> -Ref <ref> -Desc <desc>

  # normal (opens PR)
  .\tools\mep_idea_receipt.ps1 -IdeaId <12chars> -Ref <ref> -Desc <desc>

Rules:
  - IdeaId must be exactly 12 characters.
  - Ref/Desc are required unless -Help is specified.
"@
}

if ($Help) { Show-Usage; exit 0 }

if (-not $IdeaId -or $IdeaId.Length -ne 12) { Write-Error "IdeaId must be exactly 12 characters."; exit 2 }
if ([string]::IsNullOrWhiteSpace($Ref)) { Write-Error "Ref is required."; exit 2 }
if ([string]::IsNullOrWhiteSpace($Desc)) { Write-Error "Desc is required."; exit 2 }

$line = "IDEA:$IdeaId  RESULT: implemented  REF: $Ref  DESC: $Desc"

if ($DryRun) {
  Write-Host $line
  exit 0
}

# GitHub PR workflow (GitHub is source of truth)
$ErrorActionPreference = "Stop"
$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$branch = ("work/idea-receipt-{0}-{1}" -f $IdeaId, $stamp)

$mainRef = gh api ("repos/{0}/git/ref/heads/main" -f $repo) | ConvertFrom-Json
$mainSha = $mainRef.object.sha
gh api -X POST ("repos/{0}/git/refs" -f $repo) -f ("ref=refs/heads/{0}" -f $branch) -f ("sha={0}" -f $mainSha) | Out-Null

function Get-RepoFile {
  param([string]$Path,[string]$Ref)
  $obj = gh api ("repos/{0}/contents/{1}?ref={2}" -f $repo, $Path, $Ref) | ConvertFrom-Json
  $b64 = ($obj.content -replace '\s','')
  $bytes = [Convert]::FromBase64String($b64)
  $text = [Text.Encoding]::UTF8.GetString($bytes)
  return [pscustomobject]@{ sha=$obj.sha; text=$text }
}

function Put-RepoFile {
  param([string]$Path,[string]$Branch,[string]$Message,[string]$NewText,[string]$OldSha)
  if (-not $NewText.EndsWith("`n")) { $NewText += "`n" }
  $newB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($NewText))
  gh api -X PUT ("repos/{0}/contents/{1}" -f $repo, $Path) `
    -f ("message={0}" -f $Message) `
    -f ("content={0}" -f $newB64) `
    -f ("sha={0}" -f $OldSha) `
    -f ("branch={0}" -f $Branch) | Out-Null
}

$path = "docs/MEP/IDEA_RECEIPTS.md"
$f = Get-RepoFile -Path $path -Ref "main"

# append under RECEIPTS section (simple append at EOF is acceptable because file is append-only ledger)
$newText = $f.text.TrimEnd() + "`n" + $line + "`n"
Put-RepoFile -Path $path -Branch $branch -Message "docs(MEP): append IDEA receipt ($IdeaId)" -NewText $newText -OldSha $f.sha

$title = "docs(MEP): IDEA receipt $IdeaId"
$body = "Append one implemented receipt line to IDEA_RECEIPTS.`n`n$line"
gh pr create --base main --head $branch --title $title --body $body | Out-Null

Write-Host "PR created."
