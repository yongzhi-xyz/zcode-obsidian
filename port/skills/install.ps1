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
if (-not $Destination) { Write-Output "ERROR: destination is empty"; exit 1 }

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
if (-not (Test-Path $Destination)) { Write-Output "ERROR: cannot create destination: $Destination"; exit 1 }

foreach ($n in $names) {
  $src = Join-Path $SkillsSource $n
  if (-not (Test-Path $src)) { Write-Output "skip (missing): $n"; continue }
  $p = Join-Path $Destination $n
  if (-not $p) { Write-Output "ERROR: bad destination for $n"; exit 1 }
  if (Test-Path $p) { Remove-Item $p -Recurse -Force }
  try { Copy-Item $src $p -Recurse -ErrorAction Stop } catch {
    Write-Output "ERROR: install failed for ${n}: $($_.Exception.Message)"; exit 1
  }
  Write-Output "installed: $n"
}

# Substitute <distro>/<user> placeholders in installed skill docs.
# Literal .Replace() only - regex replacement side would double the backslashes.
if ($uncVault) {
  $vaultRelWin = $vaultRel -replace '/', '\'
  $ph = '\\wsl.localhost\<distro>\home\<user>\' + $vaultRelWin
  foreach ($md in (Get-ChildItem $Destination -Recurse -Filter *.md)) {
    $text = Get-Content $md.FullName -Raw
    if ($text -and $text.Contains("<distro>")) {
      $text = $text.Replace($ph, $uncVault)
      Set-Content -Path $md.FullName -Value $text -Encoding UTF8 -NoNewline
    }
  }
}

Write-Output "done. 15 skills take effect in a NEW Zcode session."
