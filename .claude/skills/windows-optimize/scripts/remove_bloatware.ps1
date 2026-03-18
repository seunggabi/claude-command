# Bloatware Removal Script
# Removes common unnecessary Windows components for server environments
# Usage: .\remove_bloatware.ps1 [-OneDrive] [-Teams] [-EdgeAutoLaunch] [-DiagTrack] [-MapsBroker]

param(
    [switch]$OneDrive,
    [switch]$Teams,
    [switch]$EdgeAutoLaunch,
    [switch]$DiagTrack,
    [switch]$MapsBroker,
    [switch]$All
)

if ($All) { $OneDrive = $Teams = $EdgeAutoLaunch = $DiagTrack = $MapsBroker = $true }

$regRun = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
)

# --- OneDrive ---
if ($OneDrive) {
    Write-Output "=== Removing OneDrive ==="
    Get-Process OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force
    foreach ($p in $regRun) {
        Remove-ItemProperty -Path $p -Name "OneDrive" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $p -Name "OneDriveSetup" -ErrorAction SilentlyContinue
    }
    $setupExe = "$env:SystemRoot\System32\OneDriveSetup.exe"
    if (Test-Path $setupExe) { Start-Process $setupExe "/uninstall" -Wait -ErrorAction SilentlyContinue }
    @(
        "$env:USERPROFILE\OneDrive",
        "$env:LOCALAPPDATA\Microsoft\OneDrive",
        "$env:PROGRAMDATA\Microsoft OneDrive",
        "$env:SYSTEMDRIVE\OneDriveTemp"
    ) | Where-Object { Test-Path $_ } | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue; Write-Output "  Removed: $_" }
    $gpo = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
    if (-not (Test-Path $gpo)) { New-Item -Path $gpo -Force | Out-Null }
    Set-ItemProperty -Path $gpo -Name "DisableFileSyncNGSC" -Value 1 -Type DWord
    Write-Output "  OneDrive permanently blocked via group policy"
}

# --- Teams ---
if ($Teams) {
    Write-Output "=== Removing Teams ==="
    Get-Process -Name "ms-teams","Teams","MSTeams" -ErrorAction SilentlyContinue | Stop-Process -Force
    foreach ($p in $regRun) {
        Remove-ItemProperty -Path $p -Name "Teams" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $p -Name "MSTeams" -ErrorAction SilentlyContinue
    }
    Get-AppxPackage -Name "MSTeams" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxPackage -Name "MicrosoftTeams" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    @(
        "$env:LOCALAPPDATA\Microsoft\Teams",
        "$env:LOCALAPPDATA\Microsoft\TeamsMeetingAddin",
        "$env:APPDATA\Microsoft\Teams"
    ) | Where-Object { Test-Path $_ } | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue; Write-Output "  Removed: $_" }
    Write-Output "  Teams removed"
}

# --- Edge Auto-Launch ---
if ($EdgeAutoLaunch) {
    Write-Output "=== Disabling Edge Auto-Launch ==="
    $runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    Get-Item $runKey -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Property |
        Where-Object { $_ -like "*Edge*" } |
        ForEach-Object { Remove-ItemProperty -Path $runKey -Name $_ -ErrorAction SilentlyContinue }
    $edgePolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    if (-not (Test-Path $edgePolicy)) { New-Item -Path $edgePolicy -Force | Out-Null }
    Set-ItemProperty -Path $edgePolicy -Name "StartupBoostEnabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $edgePolicy -Name "BackgroundModeEnabled" -Value 0 -Type DWord
    Write-Output "  Edge startup boost and background mode disabled"
}

# --- DiagTrack (Telemetry) ---
if ($DiagTrack) {
    Write-Output "=== Disabling DiagTrack ==="
    Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service dmwappushservice -Force -ErrorAction SilentlyContinue
    Set-Service dmwappushservice -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Output "  DiagTrack (telemetry) disabled"
}

# --- MapsBroker ---
if ($MapsBroker) {
    Write-Output "=== Disabling MapsBroker ==="
    Stop-Service MapsBroker -Force -ErrorAction SilentlyContinue
    Set-Service MapsBroker -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Output "  MapsBroker (Windows Maps) disabled"
}

Write-Output ""
Write-Output "Done."
