$VC = Read-Host " Enter vCenter name:" 
$LUNId = Read-Host "Enter your LUN Id wildcard, like naa.60002ac* "
Connect-VIServer $VC

Get-Cluster | Select name | FT
$Cluster = Read-Host " Enter Cluster name from list above:"
$VMhosts = Get-cluster $cluster | Get-VMHost 

Foreach ($VMhost in $VMhosts) {
      Write-Host "SettingMultipath Policy on $VMhost to Round Robin with this mask $LUNId" -ForegroundColor Green
      Get-VMHost $VMhost | Get-ScsiLun -CanonicalName $LUNId -LunType Disk | Where {$_.MultipathPolicy-notlike "RoundRobin"} | Set-Scsilun -MultiPathPolicy RoundRobin
      Get-VMhost $VMhost | Get-ScsiLun -CanonicalName $LUNId -LunType Disk | Where-Object {$_.CanonicalName-like $LUNId -and $_.MultipathPolicy-like ‘RoundRobin’ } | Set-ScsiLun -CommandsToSwitchPath 1
      } 

Write-host "disconnecting from $VC" -ForegroundColor Yellow
Disconnect-VIServer -Server * -Confirm:$False