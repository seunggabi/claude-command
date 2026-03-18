# Disk Cleanup Script
# Removes temporary files to free up C drive space

param(
    [switch]$WhatIf
)

function Get-FolderSizeMB($path) {
    if (Test-Path $path) {
        $size = (Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        return [math]::Round($size / 1MB, 1)
    }
    return 0
}

$targets = @(
    "C:\Windows\Temp",
    "C:\Windows\SoftwareDistribution\Download",
    "$env:LOCALAPPDATA\Temp"
)

# Calculate total size before
$totalMB = 0
foreach ($t in $targets) {
    $mb = Get-FolderSizeMB $t
    $totalMB += $mb
    Write-Output "  $mb MB  $t"
}
Write-Output ""
Write-Output "Total to clean: $totalMB MB"

if ($WhatIf) { exit 0 }

Write-Output "Cleaning..."

# Windows Temp
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Windows Update cache
Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service wuauserv -ErrorAction SilentlyContinue

# User Temp folders
Remove-Item "$env:LOCALAPPDATA\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item "$($_.FullName)\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output "Done. Freed approximately $totalMB MB."
