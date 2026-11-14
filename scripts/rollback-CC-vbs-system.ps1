$a = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
$b = "$a\Scenarios\HypervisorEnforcedCodeIntegrity"
foreach ($n in "EnableVirtualizationBasedSecurity", "RequirePlatformSecurityFeatures") { Remove-ItemProperty -Path $a -Name $n -ErrorAction SilentlyContinue }
foreach ($n in "Enabled", "Locked") { Remove-ItemProperty -Path $b -Name $n -ErrorAction SilentlyContinue }
Get-ItemProperty $a | Select-Object EnableVirtualizationBasedSecurity, RequirePlatformSecurityFeatures | Format-List
Get-ItemProperty $b | Select-Object Enabled, Locked | Format-List
