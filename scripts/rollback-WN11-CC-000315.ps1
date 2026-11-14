<#
.SYNOPSIS
    Rollback for WN11-CC-000315. Removes the AlwaysInstallElevated value that the fix
    script created, then removes the Installer key if it is now empty, returning the
    registry to its pre-fix state (setting not configured = NULL).

.NOTES
    STIG-ID         : WN11-CC-000315
    Pairs with      : WN11-CC-000315.ps1
    Drafted by      : Cortana (Claude), Module 8 training, 11-09-2026
    Run as          : Administrator
#>

$paths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer",
    "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer"
)
$name = "AlwaysInstallElevated"

foreach ($path in $paths) {
    if (Test-Path $path) {
        # Remove the value if it exists
        if (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -Path $path -Name $name
            Write-Host "Removed $name from $path" -ForegroundColor Yellow
        }
        # Remove the key only if nothing else is inside it
        $key = Get-Item -Path $path
        if ($key.ValueCount -eq 0 -and $key.SubKeyCount -eq 0) {
            Remove-Item -Path $path
            Write-Host "Removed empty key $path" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Nothing to roll back in $path" -ForegroundColor Cyan
    }
}