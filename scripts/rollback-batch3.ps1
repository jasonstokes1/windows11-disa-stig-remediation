<#
.SYNOPSIS
    ROLLBACK for batch 3 (WN11-SO Security Options). Do not run unless
    batch 3 must be undone.
.NOTES
    Author        : Jason Stokes (script drafted with Claude)
    Date Created  : 2026-11-11
    Undoes        : WN11-SO-batch3.ps1
    Reads         : C:\Scripts\so-before-batch3.csv (written by the batch)
    Method        : value existed before -> write the original value back;
                    value did not exist -> delete it;
                    Guest account -> rename back to the original name.
                    Registry keys created by the batch are left in place (empty keys do nothing).
.USAGE
    Run in an administrator PowerShell:
    powershell -ExecutionPolicy Bypass -File "C:\Scripts\rollback-batch3.ps1"
#>

$beforeFile = 'C:\Scripts\so-before-batch3.csv'

if (-not (Test-Path $beforeFile)) {
    Write-Host "STOP: $beforeFile not found. Nothing to roll back." -ForegroundColor Red
    exit 1
}

$rows = Import-Csv -Path $beforeFile

foreach ($r in $rows) {
    if ($r.Path -eq 'LocalUser') {
        $g = Get-LocalUser | Where-Object { $_.SID.Value -like '*-501' }
        if ($g.Name -ne $r.Value) { Rename-LocalUser -SID $g.SID -NewName $r.Value }
        Write-Host "$($r.Rule)  Guest account name restored to $($r.Value)"
        continue
    }
    if ($r.Existed -eq 'Yes') {
        New-ItemProperty -Path $r.Path -Name $r.Name -PropertyType $r.Type -Value $r.Value -Force | Out-Null
        Write-Host "$($r.Rule)  Restored $($r.Name) = $($r.Value)"
    } else {
        Remove-ItemProperty -Path $r.Path -Name $r.Name -ErrorAction SilentlyContinue
        Write-Host "$($r.Rule)  Removed $($r.Name) (did not exist before)"
    }
}

Write-Host "Rollback of batch 3 complete. Restart the VM to make sure every setting reloads." -ForegroundColor Green