<#
.SYNOPSIS
    ROLLBACK for batch 2 (WN11-AU audit policy group). Do not run unless
    batch 2 must be undone.
.NOTES
    Author        : Jason Stokes (script drafted with Claude)
    Date Created  : 2026-11-11
    Undoes        : WN11-AU-batch2.ps1
    Part 1        : restores all audit subcategories from the backup taken
                    2026-11-11 16:34 UTC (auditpol-before-batch2.csv)
    Part 2        : deletes the 2 MaxSize values (baseline = not set);
                    deletes each key only if it is then empty
.USAGE
    Run in an administrator PowerShell:
    powershell -ExecutionPolicy Bypass -File "C:\Scripts\rollback-batch2.ps1"
#>

$backup = 'C:\Scripts\auditpol-before-batch2.csv'

Write-Host "=== Part 1: restore audit policy from backup ===" -ForegroundColor Cyan
if (Test-Path $backup) {
    auditpol /restore /file:$backup
} else {
    Write-Host "Backup file not found: $backup. Audit policy NOT restored." -ForegroundColor Red
}

Write-Host "=== Part 2: remove event log MaxSize values ===" -ForegroundColor Cyan
$paths = @(
    'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security',
    'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System'
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Remove-ItemProperty -Path $path -Name 'MaxSize' -ErrorAction SilentlyContinue
        $key = Get-Item -Path $path
        if ($key.ValueCount -eq 0 -and $key.SubKeyCount -eq 0) {
            Remove-Item -Path $path
            Write-Host "Removed empty key: $path"
        } else {
            Write-Host "Removed MaxSize; key kept (still has other values): $path"
        }
    } else {
        Write-Host "Key not present, nothing to remove: $path"
    }
}

Write-Host "Rollback complete. Verify with: auditpol /get /category:*" -ForegroundColor Green