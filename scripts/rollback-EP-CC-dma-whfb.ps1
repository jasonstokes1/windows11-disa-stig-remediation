$a = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection"
$b = "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork"
Remove-ItemProperty -Path $a -Name "DeviceEnumerationPolicy" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $b -Name "RequireSecurityDevice" -ErrorAction SilentlyContinue
"DeviceEnumerationPolicy = " + (Get-ItemProperty -Path $a).DeviceEnumerationPolicy
"RequireSecurityDevice = " + (Get-ItemProperty -Path $b).RequireSecurityDevice
