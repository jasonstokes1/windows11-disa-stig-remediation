$a = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
$b = "$a\Scenarios\HypervisorEnforcedCodeIntegrity"
if (-not (Test-Path $b)) { New-Item -Path $b -Force | Out-Null }
New-ItemProperty -Path $a -Name "EnableVirtualizationBasedSecurity" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $a -Name "RequirePlatformSecurityFeatures" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $b -Name "Enabled" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $b -Name "Locked" -Value 0 -PropertyType DWord -Force | Out-Null
Get-ItemProperty $a | Select-Object EnableVirtualizationBasedSecurity, RequirePlatformSecurityFeatures | Format-List
Get-ItemProperty $b | Select-Object Enabled, Locked | Format-List
