# rollback-batch5.ps1 - drafted with Claude. Restores before values (seclogon Manual; 3 values did not exist).
Set-Service -Name seclogon -StartupType Manual
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount' -Name DisableUserAuth -ErrorAction SilentlyContinue
Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' -Name DisableExceptionChainValidation -ErrorAction SilentlyContinue
Remove-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications' -Name NoToastApplicationNotificationOnLockScreen -ErrorAction SilentlyContinue
Write-Host 'Batch 5 rolled back.'
