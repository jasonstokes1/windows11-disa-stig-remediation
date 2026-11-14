# WN11-batch5.ps1 - drafted with Claude. Rules 00-000175, 00-000126, 00-000150, UC-000015.
$acct = 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount'
$kern = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel'
$push = 'HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications'
Set-Service -Name seclogon -StartupType Disabled
foreach ($k in $acct, $kern, $push) { if (-not (Test-Path $k)) { New-Item -Path $k -Force | Out-Null } }
New-ItemProperty -Path $acct -Name DisableUserAuth -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $kern -Name DisableExceptionChainValidation -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $push -Name NoToastApplicationNotificationOnLockScreen -Value 1 -PropertyType DWord -Force | Out-Null
"00-000175 seclogon StartType: " + (Get-Service seclogon).StartType
"00-000126 DisableUserAuth: " + (Get-ItemProperty $acct).DisableUserAuth
"00-000150 DisableExceptionChainValidation: " + (Get-ItemProperty $kern).DisableExceptionChainValidation
"UC-000015 NoToastApplicationNotificationOnLockScreen: " + (Get-ItemProperty $push).NoToastApplicationNotificationOnLockScreen
