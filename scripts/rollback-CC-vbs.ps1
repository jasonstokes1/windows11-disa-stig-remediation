$p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
foreach ($n in "EnableVirtualizationBasedSecurity", "RequirePlatformSecurityFeatures", "HypervisorEnforcedCodeIntegrity") { Remove-ItemProperty -Path $p -Name $n -ErrorAction SilentlyContinue }
Get-ItemProperty $p | Select-Object EnableVirtualizationBasedSecurity, RequirePlatformSecurityFeatures, HypervisorEnforcedCodeIntegrity
