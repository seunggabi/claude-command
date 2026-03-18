# Windows Services Reference

## Safe to Disable (Server Environments)

| Service | Name | Why Disable |
|---------|------|-------------|
| DiagTrack | Connected User Experiences and Telemetry | Sends usage data to Microsoft. No server value. |
| MapsBroker | Downloaded Maps Manager | Windows Maps app background sync. Useless on server. |
| SysMain | Superfetch | Preloads apps into RAM. Counterproductive with MySQL (which manages its own buffer pool). Keep if no heavy DB. |
| WSearch | Windows Search | File indexing. High disk I/O. Disable if not using Windows search. |
| Fax | Fax | Fax service. Almost never needed. |
| RemoteRegistry | Remote Registry | Security risk. Disable unless specifically needed. |
| RetailDemo | Retail Demo Service | Demo mode. No purpose on real machines. |
| XblAuthManager | Xbox Live Auth Manager | Xbox gaming. Not needed on server. |
| XblGameSave | Xbox Live Game Save | Xbox gaming. Not needed on server. |
| XboxNetApiSvc | Xbox Live Networking | Xbox gaming. Not needed on server. |
| PrintSpooler | Print Spooler | Only needed if printer is connected. Security risk if not. |

## Keep Enabled (Server Environments)

| Service | Why Keep |
|---------|---------|
| WinDefend | Windows Defender antivirus. Essential baseline protection. |
| WSearch | Keep if users rely on Windows file search. |
| SysMain | Keep if not running heavy memory-managed services (MySQL, etc.). |
| wuauserv | Windows Update. Keep enabled for security patches. |
| EventLog | Windows Event Log. Critical for troubleshooting. |

## How to Disable a Service

```powershell
Stop-Service <ServiceName> -Force
Set-Service <ServiceName> -StartupType Disabled
```

## How to Check Running Services

```powershell
# All running services
Get-Service | Where-Object { $_.Status -eq 'Running' } | Sort-Object DisplayName

# Check specific service
Get-Service DiagTrack
```
