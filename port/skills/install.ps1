# zcode-obsidian skill installer: repo port/skills/ -> Zcode user skills dir
# ASCII only (PowerShell 5.1 treats BOM-less UTF-8 scripts as ANSI).
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File install.ps1
#     [-SkillsSource <dir>] [-Destination <dir>] [-WslDistro <name>]
#     [-WslUser <name>] [-VaultPath <linux-path>] [-Uninstall]
#
# Defaults: source = this script's dir; destination = %USERPROFILE%\.zcode\skills
#           distro/user auto-detected via wsl; vault = ~/vaults/kb
# Placeholders like \\wsl.localhost\<distro>\home\<user>\vaults\kb in skill
# templates are replaced with the resolved values at install time.
param(
  [string]$SkillsSource = "",
  [string]$Destination = "$env:USERPROFILE\.zcode\skills",
  [string]$WslDistro = "",
  [string]$WslUser = "",
  [string]$VaultPath = "~/vaults/kb",
  [switch]$Uninstall
)

if (-not $SkillsSource) { $SkillsSource = $PSScriptRoot }

$names = @(
  "obsidian-wiki", "obsidian-save", "obsidian-ingest", "obsidian-query", "obsidian-lint",
  "obsidian-fold", "obsidian-mode", "obsidian-retrieve", "obsidian-cli", "obsidian-autoresearch",
  "obsidian-canvas", "obsidian-defuddle", "obsidian-markdown", "obsidian-bases", "obsidian-think"
)

if ($Uninstall) {
  foreach ($n in $names) {
    $p = Join-Path $Destination $n
    if (Test-Path $p) { Remove-Item $p -Recurse -Force; Write-Output "removed: $n" }
  }
  exit 0
}

if (-not (Test-Path $SkillsSource)) { Write-Output "ERROR: skills source not found: $SkillsSource"; exit 1 }

# Resolve WSL distro/user unless provided.
if (-not $WslDistro) {
  $first = (wsl -l -q) | Where-Object { $_ } | Select-Object -First 1
  $WslDistro = ($first -replace "`0", "").Trim()
}
if ($WslDistro) {
  Write-Output "distro: $WslDistro"
  if (-not $WslUser) {
    $WslUser = (wsl -d $WslDistro -- whoami)
    if ($WslUser) { $WslUser = ($WslUser -replace "`0", "").Trim() }
  }
}
if ($WslUser) { Write-Output "wsl user: $WslUser" }

# Build the concrete UNC vault root used to replace template placeholders.
$vaultRel = $VaultPath
if ($vaultRel.StartsWith("~/")) { $vaultRel = $vaultRel.Substring(2) }
$uncVault = $null
if ($WslDistro -and $WslUser) {
  $uncVault = "\\wsl.localhost\$WslDistro\home\$WslUser\" + ($vaultRel -replace "/", "\")
  Write-Output "vault UNC: $uncVault"
}

New-Item -ItemType Directory -Path $Destination -Force | Out-Null

foreach ($n in $names) {
  $src = Join-Path $SkillsSource $n
  if (-not (Test-Path $src)) { Write-Output "skip (missing): $n"; continue }
  $p = Join-Path $Destination $n
  if (Test-Path $p) { Remove-Item $p -Recurse -Force }
  Copy-Item $src $p -Recurse
  Write-Output "installed: $n"
}

# Substitute <distro>/<user> placeholders in installed skill docs.
if ($uncVault) {
  $pattern = '\\\\wsl\.localhost\\<distro>\\home\\<user>\\' + ($vaultRel -replace '/', '\\')
  foreach ($md in (Get-ChildItem $Destination -Recurse -Filter *.md)) {
    $text = Get-Content $md.FullName -Raw
    if ($text -and $text.Contains("<distro>")) {
      $text = $text -replace $pattern, ($uncVault -replace '\\', '\\')
      Set-Content -Path $md.FullName -Value $text -Encoding UTF8 -NoNewline
    }
  }
}

Write-Output "done. 15 skills take effect in a NEW Zcode session."
