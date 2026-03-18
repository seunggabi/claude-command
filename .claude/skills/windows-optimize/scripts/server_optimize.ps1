# Server Optimization Script
# Configures pagefile, power plan, and sleep settings for always-on servers

# 1. Set pagefile to fixed 8GB
$cs = Get-WmiObject Win32_ComputerSystem
$cs.AutomaticManagedPagefile = $false
$cs.Put() 2>$null

$pf = Get-WmiObject Win32_PageFileSetting
if ($pf) {
    $pf.InitialSize = 8192
    $pf.MaximumSize = 8192
    $pf.Put()
} else {
    Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{
        Name        = "C:\pagefile.sys"
        InitialSize = 8192
        MaximumSize = 8192
    }
}
Write-Output "Pagefile: fixed 8 GB"

# 2. High performance power plan
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
Write-Output "Power plan: High Performance"

# 3. Disable all sleep/monitor timeouts (AC power)
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /change monitor-timeout-ac 0
Write-Output "Sleep/monitor timeouts: disabled"

Write-Output ""
Write-Output "NOTE: Pagefile change requires reboot to take effect."
