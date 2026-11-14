<#
.SYNOPSIS
    Batch 2 of DISA Windows 11 STIG fixes: audit policy (WN11-AU group).
    Turns on 19 audit subcategories and sets 2 event log maximum sizes.
.NOTES
    Author        : Jason Stokes (script drafted with Claude)
    Date Created  : 2026-11-11
    STIG          : DISA Microsoft Windows 11 STIG v2r11 (Tenable audit)
    STIG IDs      : WN11-AU-000005, 000010, 000035, 000045, 000054, 000060,
                    000081, 000082, 000083, 000084, 000085, 000090, 000107,
                    000110, 000115, 000120, 000150, 000505, 000510, 000555,
                    000560, 000565, 000570, 000575, 000580, 000583, 000585,
                    000586, 000587, 000588, 000589 (31 rules)
    Tested on     : jps-win11-stig0, Windows 11 Pro 25H2
    Backup taken  : auditpol /backup /file:C:\Scripts\auditpol-before-batch2.csv
    Rollback      : auditpol /restore /file:C:\Scripts\auditpol-before-batch2.csv
                    plus rollback-batch2.ps1 for the 2 registry values
.USAGE
    Run in an administrator PowerShell:
    powershell -ExecutionPolicy Bypass -File "C:\Scripts\WN11-AU-batch2.ps1"
    Only ENABLES switches; never turns any existing switch off.
#>

Write-Host "=== Part 1: audit subcategories ===" -ForegroundColor Cyan

# System
auditpol /set /subcategory:"Security System Extension" /success:enable                   # AU-000150
auditpol /set /subcategory:"IPsec Driver" /failure:enable                                # AU-000120

# Logon/Logoff
auditpol /set /subcategory:"Account Lockout" /failure:enable                             # AU-000054
auditpol /set /subcategory:"Other Logon/Logoff Events" /success:enable /failure:enable   # AU-000560, 000565
auditpol /set /subcategory:"Group Membership" /success:enable                            # AU-000060

# Object Access
auditpol /set /subcategory:"Registry" /success:enable /failure:enable                    # AU-000586, 000589
auditpol /set /subcategory:"Handle Manipulation" /failure:enable                         # AU-000583
auditpol /set /subcategory:"File Share" /success:enable /failure:enable                  # AU-000081, 000082
auditpol /set /subcategory:"Other Object Access Events" /success:enable /failure:enable  # AU-000083, 000084
auditpol /set /subcategory:"Detailed File Share" /failure:enable                         # AU-000570
auditpol /set /subcategory:"Removable Storage" /success:enable /failure:enable           # AU-000085, 000090

# Privilege Use
auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable     # AU-000110, 000115, 000587, 000588

# Detailed Tracking
auditpol /set /subcategory:"Process Creation" /failure:enable                            # AU-000585
auditpol /set /subcategory:"Plug and Play Events" /success:enable                        # AU-000045

# Policy Change
auditpol /set /subcategory:"Authorization Policy Change" /success:enable                 # AU-000107
auditpol /set /subcategory:"MPSSVC Rule-Level Policy Change" /success:enable /failure:enable  # AU-000575, 000580
auditpol /set /subcategory:"Other Policy Change Events" /failure:enable                  # AU-000555

# Account Management
auditpol /set /subcategory:"User Account Management" /failure:enable                     # AU-000035

# Account Logon
auditpol /set /subcategory:"Credential Validation" /success:enable /failure:enable       # AU-000005, 000010

Write-Host "=== Part 2: event log maximum sizes (KB) ===" -ForegroundColor Cyan

$logs = @(
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security'; Size = 5120000; Rule = 'WN11-AU-000505' },
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System';   Size = 32768;   Rule = 'WN11-AU-000510' }
)

foreach ($log in $logs) {
    $before = (Get-ItemProperty -Path $log.Path -Name 'MaxSize' -ErrorAction SilentlyContinue).MaxSize
    if ($null -eq $before) { $before = '(not set)' }
    Write-Host "$($log.Rule) BEFORE: MaxSize = $before"

    if (-not (Test-Path $log.Path)) { New-Item -Path $log.Path -Force | Out-Null }
    New-ItemProperty -Path $log.Path -Name 'MaxSize' -PropertyType DWord -Value $log.Size -Force | Out-Null

    $after = (Get-ItemProperty -Path $log.Path -Name 'MaxSize').MaxSize
    Write-Host "$($log.Rule) AFTER:  MaxSize = $after" -ForegroundColor Green
}

Write-Host "=== Part 3: verify audit settings ===" -ForegroundColor Cyan
auditpol /get /category:*

Write-Host "Batch 2 complete. Compare Part 3 with the target table, then rescan." -ForegroundColor Green