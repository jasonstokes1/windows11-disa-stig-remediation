<#
.SYNOPSIS
    Batch 3 of DISA Windows 11 STIG fixes: Security Options (WN11-SO group).
    Fixes 16 rules. Saves every original value first so it can be rolled back.
.NOTES
    Author        : Jason Stokes (script drafted with Claude)
    Date Created  : 2026-11-11
    STIG          : DISA Microsoft Windows 11 STIG v2r11 (Tenable audit)
    STIG IDs      : WN11-SO-000025, 000030, 000070, 000095, 000100, 000120,
                    000150, 000167, 000180, 000185, 000190, 000205, 000215,
                    000220, 000250, 000255 (16 rules)
    Deferred      : 000230 FIPS (can break TLS/RDP), 000245 UAC for built-in
                    Administrator (can block Tenable admin logon), 000280 LAPS
                    (needs domain/Entra), 000075 logon banner (exact DoD text)
    Tested on     : jps-win11-stig0, Windows 11 Pro 25H2
    Before values : C:\Scripts\so-before-batch3.csv (written by this script)
    Rollback      : rollback-batch3.ps1 (reads the before file)
.USAGE
    Run in an administrator PowerShell:
    powershell -ExecutionPolicy Bypass -File "C:\Scripts\WN11-SO-batch3.ps1"
#>

$beforeFile = 'C:\Scripts\so-before-batch3.csv'
$lsa = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$msv = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0'
$pol = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

$settings = @(
    @{ Rule='WN11-SO-000030'; Path=$lsa; Name='SCENoApplyLegacyAuditPolicy'; Type='DWord';  Value=1 },
    @{ Rule='WN11-SO-000070'; Path=$pol; Name='InactivityTimeoutSecs';       Type='DWord';  Value=900 },
    @{ Rule='WN11-SO-000095'; Path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'; Name='SCRemoveOption'; Type='String'; Value='1' },
    @{ Rule='WN11-SO-000100'; Path='HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters'; Name='RequireSecuritySignature'; Type='DWord'; Value=1 },
    @{ Rule='WN11-SO-000120'; Path='HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters';      Name='RequireSecuritySignature'; Type='DWord'; Value=1 },
    @{ Rule='WN11-SO-000150'; Path=$lsa; Name='RestrictAnonymous';           Type='DWord';  Value=1 },
    @{ Rule='WN11-SO-000167'; Path=$lsa; Name='RestrictRemoteSAM';           Type='String'; Value='O:BAG:BAD:(A;;RC;;;BA)' },
    @{ Rule='WN11-SO-000180'; Path=$msv; Name='allownullsessionfallback';    Type='DWord';  Value=0 },
    @{ Rule='WN11-SO-000185'; Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u'; Name='AllowOnlineID'; Type='DWord'; Value=0 },
    @{ Rule='WN11-SO-000190'; Path="$pol\Kerberos\Parameters"; Name='SupportedEncryptionTypes'; Type='DWord'; Value=2147483640 },
    @{ Rule='WN11-SO-000205'; Path=$lsa; Name='LmCompatibilityLevel';        Type='DWord';  Value=5 },
    @{ Rule='WN11-SO-000215'; Path=$msv; Name='NTLMMinClientSec';            Type='DWord';  Value=537395200 },
    @{ Rule='WN11-SO-000220'; Path=$msv; Name='NTLMMinServerSec';            Type='DWord';  Value=537395200 },
    @{ Rule='WN11-SO-000250'; Path=$pol; Name='ConsentPromptBehaviorAdmin';  Type='DWord';  Value=2 },
    @{ Rule='WN11-SO-000255'; Path=$pol; Name='ConsentPromptBehaviorUser';   Type='DWord';  Value=0 }
)

# Safety: never overwrite the original before-values on a second run
if (Test-Path $beforeFile) {
    Write-Host "STOP: $beforeFile already exists (batch 3 already ran). Nothing changed." -ForegroundColor Red
    exit 1
}

Write-Host "=== Part 1: save BEFORE values ===" -ForegroundColor Cyan
$before = @()
foreach ($s in $settings) {
    $item = Get-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue
    if ($null -ne $item) {
        $kind = (Get-Item -Path $s.Path).GetValueKind($s.Name)
        $before += [pscustomobject]@{ Rule=$s.Rule; Path=$s.Path; Name=$s.Name; Existed='Yes'; Type="$kind"; Value=$item.($s.Name) }
    } else {
        $before += [pscustomobject]@{ Rule=$s.Rule; Path=$s.Path; Name=$s.Name; Existed='No'; Type=''; Value='' }
    }
}
$guest = Get-LocalUser | Where-Object { $_.SID.Value -like '*-501' }
$before += [pscustomobject]@{ Rule='WN11-SO-000025'; Path='LocalUser'; Name='GuestAccountName'; Existed='Yes'; Type='Name'; Value=$guest.Name }
$before | Export-Csv -Path $beforeFile -NoTypeInformation
$before | Format-Table Rule, Name, Existed, Value -AutoSize

Write-Host "=== Part 2: apply 16 settings ===" -ForegroundColor Cyan
foreach ($s in $settings) {
    if (-not (Test-Path $s.Path)) { New-Item -Path $s.Path -Force | Out-Null }
    New-ItemProperty -Path $s.Path -Name $s.Name -PropertyType $s.Type -Value $s.Value -Force | Out-Null
}
Rename-LocalUser -SID $guest.SID -NewName 'jps-visitor'

Write-Host "=== Part 3: verify AFTER values ===" -ForegroundColor Cyan
foreach ($s in $settings) {
    $v = (Get-ItemProperty -Path $s.Path -Name $s.Name).($s.Name)
    Write-Host ("{0}  {1} = {2}" -f $s.Rule, $s.Name, $v) -ForegroundColor Green
}
Write-Host ("WN11-SO-000025  Guest account name = {0}" -f (Get-LocalUser -SID $guest.SID).Name) -ForegroundColor Green
Write-Host "Batch 3 complete. Do NOT sign out until a second Bastion logon is tested." -ForegroundColor Yellow