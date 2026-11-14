# rollback-SO-000075.ps1 - drafted with Claude. Puts the logon notice back to blank (before value).
$key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-ItemProperty -Path $key -Name LegalNoticeCaption -Value '' -Type String
Set-ItemProperty -Path $key -Name LegalNoticeText -Value '' -Type String
Write-Host 'Logon notice cleared.'
