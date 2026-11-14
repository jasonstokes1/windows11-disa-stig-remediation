$p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
New-ItemProperty -Path $p -Name "EnableVirtualizationBasedSecurity" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $p -Name "RequirePlatformSecurityFeatures" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $p -Name "HypervisorEnforcedCodeIntegrity" -Value 2 -PropertyType DWord -Force | Out-Null
Get-ItemProperty $p | Select-Object EnableVirtualizationBasedSecurity, RequirePlatformSecurityFeatures, HypervisorEnforcedCodeIntegrity
