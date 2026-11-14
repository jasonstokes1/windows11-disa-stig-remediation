# WN11 CC Remote Desktop (3 rules) - drafted with Claude
$p="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"; $r="fPromptForPassword|1","fEncryptRPCTraffic|1","MinEncryptionLevel|3"
if(-not (Test-Path $p)){New-Item -Path $p -Force | Out-Null}; foreach($i in $r){$n,$d=$i -split "\|"; New-ItemProperty -Path $p -Name $n -Value ([int]$d) -PropertyType DWord -Force | Out-Null; "$n = " + (Get-ItemProperty -Path $p -Name $n).$n}
