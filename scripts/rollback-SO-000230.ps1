# Rollback WN11-SO-000230: restore FIPS Enabled = 0 from backup (drafted with Claude)
reg import C:\Scripts\fips-before.reg
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" -Name "Enabled" | Select-Object Enabled
