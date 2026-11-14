# Rollback WN11 CC Remote Desktop - removes the 3 values, key and batch 7 values left - drafted with Claude
$p="HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
foreach($n in "fPromptForPassword","fEncryptRPCTraffic","MinEncryptionLevel"){Remove-ItemProperty -Path $p -Name $n -ErrorAction SilentlyContinue; $v=(Get-ItemProperty -Path $p -Name $n -ErrorAction SilentlyContinue).$n; if($null -eq $v){"$n = NOT SET"}else{"$n = $v"}}
