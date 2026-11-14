<#
.SYNOPSIS
    Rollback for Module 8 batch 1 (8 STIG fixes; WN11-CC-000315 has its own rollback file).
    Registry fixes: removes the value each fix created, then removes the key only if it is
    now empty (keys that existed before the fix are never empty, so they are kept).
    Audit fix: turns Process Creation success auditing back off (baseline = No Auditing).

.NOTES
    Pairs with      : WN11-AU-000050, WN11-AU-000500, WN11-CC-000030, WN11-CC-000195,
                      WN11-CC-000200, WN11-CC-000215 (fixes WN11-CC-000190), WN11-CC-000325,
                      WN11-CC-000360
    Drafted by      : Cortana (Claude), Module 8 training, 11-10-2026
    Run as          : Administrator
#>

$items = @(
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application";          Name = "MaxSize" },
    @{ Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters";               Name = "EnableICMPRedirect" },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures";              Name = "EnhancedAntiSpoofing" },
    @{ Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\CredUI";          Name = "EnumerateAdministrators" },
    @{ Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer";        Name = "NoDriveTypeAutoRun" },
    @{ Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System";          Name = "DisableAutomaticRestartSignOn" },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client";                   Name = "AllowDigest" }
)

foreach ($item in $items) {
    $path = $item.Path
    $name = $item.Name
    if (Test-Path $path) {
        if (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -Path $path -Name $name
            Write-Host "Removed $name from $path" -ForegroundColor Yellow
        }
        $key = Get-Item -Path $path
        if ($key.ValueCount -eq 0 -and $key.SubKeyCount -eq 0) {
            Remove-Item -Path $path
            Write-Host "Removed empty key $path" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Nothing to roll back in $path" -ForegroundColor Cyan
    }
}

# WN11-AU-000050: back to baseline (Process Creation = No Auditing)
& auditpol /set /subcategory:"Process Creation" /success:disable

Write-Host "Batch 1 rollback finished. Restart is not required." -ForegroundColor Yellow