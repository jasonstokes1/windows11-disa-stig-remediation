$p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
$l = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
foreach ($k in $p, $l) { Remove-ItemProperty -Path $k -Name "LsaCfgFlags" -ErrorAction SilentlyContinue }
foreach ($k in $p, $l) { "$k : " + (Get-ItemProperty $k).LsaCfgFlags }
