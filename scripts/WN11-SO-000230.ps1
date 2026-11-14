# WN11-SO-000230: Use FIPS compliant algorithms for encryption, hashing, and signing (drafted with Claude)
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy"
Set-ItemProperty -Path $path -Name "Enabled" -Value 1 -Type DWord
Get-ItemProperty -Path $path -Name "Enabled" | Select-Object Enabled
