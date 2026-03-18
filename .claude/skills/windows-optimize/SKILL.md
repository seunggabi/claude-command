---
name: windows-optimize
description: This skill should be used when the user asks to "optimize Windows", "clean up C drive", "Windows server optimization", "disable unnecessary services", "remove bloatware", "optimize MySQL on Windows", "free up disk space on Windows", "configure power settings for server", "Windows performance tuning", "윈도우 최적화", "C드라이브 정리", "윈도우 서버 최적화", "불필요한 서비스 제거", or any task involving Windows system performance, disk cleanup, or server configuration on Windows.
---

# Windows Optimize

Performs comprehensive Windows system optimization for server and desktop environments. Covers disk cleanup, MySQL tuning, service management, and bloatware removal.

## When to Use

- User reports high disk usage on C drive
- User wants to optimize a Windows server running continuously
- User wants to remove unnecessary startup programs or services
- User wants to configure MySQL on Windows for performance
- User asks about power settings, hibernate files, or pagefile sizing

## Step 1: Assess System State

Before optimizing, gather system information:

```powershell
# Check C drive usage
Get-PSDrive C | Select-Object Used, Free

# Check large files on C root
Get-ChildItem 'C:\' -Force -ErrorAction SilentlyContinue |
    Sort-Object Length -Descending | Select-Object -First 10

# Check running services and startup programs
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command
```

Reference `references/services.md` for a list of safe-to-disable services.

## Step 2: Disk Cleanup

Run `scripts/disk_cleanup.ps1` to:
- Delete Windows Temp files (`C:\Windows\Temp`)
- Delete Windows Update cache (`SoftwareDistribution\Download`)
- Delete user Temp files (`%LOCALAPPDATA%\Temp`)

After cleanup, confirm freed space with:
```powershell
Get-PSDrive C | Select-Object Used, Free
```

## Step 3: Hibernate & Pagefile Optimization

For **server environments** (always-on):

- **Disable hibernate** → removes `hiberfil.sys` (typically 20-30 GB):
```powershell
powercfg /hibernate off
```

- **Reduce pagefile** → set to 8 GB fixed if RAM ≥ 32 GB:
Run `scripts/server_optimize.ps1`

> Note: Changes take effect after reboot. Inform the user.

## Step 4: Power Plan

For servers, set high performance power plan and disable all sleep/monitor timeouts:

```powershell
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /change monitor-timeout-ac 0
```

## Step 5: Remove Bloatware & Unnecessary Services

Run `scripts/remove_bloatware.ps1` to handle common bloatware.

Common targets (always confirm with user before removing):

| Program | Action |
|---------|--------|
| OneDrive | Uninstall + group policy block |
| Microsoft Teams | Remove AppX package + residual folders |
| Xbox services | Disable (XblAuthManager, XblGameSave, XboxNetApiSvc) |
| DiagTrack | Stop + Disable (telemetry) |
| MapsBroker | Disable (Windows Maps) |
| Edge auto-launch | Disable via registry policy |

## Step 6: MySQL Optimization (if applicable)

If MySQL is running on this server, optimize `my.ini` based on RAM.

Locate config: `C:\ProgramData\MySQL\MySQL Server X.Y\my.ini`

Reference `references/mysql.md` for recommended settings by RAM tier.

After editing, restart MySQL:
```powershell
net stop MySQL && net start MySQL
```

Verify service name first:
```powershell
sc query type= all state= all | findstr -i mysql
```

## Guidelines

1. Always assess before acting — run diagnostics first
2. Confirm with user before removing programs they might use
3. Warn about reboot requirements for pagefile/hibernate changes
4. For server environments: disable all sleep, hibernate, and monitor timeouts
5. Keep Windows Defender enabled — it's the baseline protection for Windows servers
6. Never disable WSearch without confirming user doesn't need file search
