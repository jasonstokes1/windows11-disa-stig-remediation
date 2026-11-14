$p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
$l = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
New-ItemProperty -Path $p -Name "LsaCfgFlags" -Value 2 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $l -Name "LsaCfgFlags" -Value 2 -PropertyType DWord -Force | Out-Null
foreach ($k in $p, $l) { "$k : " + (Get-ItemProperty $k).LsaCfgFlags }
