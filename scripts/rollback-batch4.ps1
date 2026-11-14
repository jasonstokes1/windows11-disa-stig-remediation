# rollback-batch4.ps1 - drafted with Claude. Restores AC + UR settings from before batch 4.
secedit /configure /db C:\Windows\security\database\rollback-batch4.sdb /cfg C:\Scripts\secpol-before-batch4.inf /areas SECURITYPOLICY USER_RIGHTS
Write-Host "Rollback done. Note: Deny log on through RDS (Guests) stays set; it was undefined before."
