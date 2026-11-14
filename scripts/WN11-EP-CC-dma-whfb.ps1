$a = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection"
$b = "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork"
foreach ($k in $a, $b) { if (-not (Test-Path $k)) { New-Item -Path $k -Force | Out-Null } }
New-ItemProperty -Path $a -Name "DeviceEnumerationPolicy" -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $b -Name "RequireSecurityDevice" -Value 1 -PropertyType DWord -Force | Out-Null
"DeviceEnumerationPolicy = " + (Get-ItemProperty -Path $a).DeviceEnumerationPolicy
"RequireSecurityDevice = " + (Get-ItemProperty -Path $b).RequireSecurityDevice
