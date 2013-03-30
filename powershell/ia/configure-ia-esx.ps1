$netapp = "vmwaredss.ccs.neu.edu"
$server = connect-viserver "ialabvsphere.ccs.neu.edu"

$cluster = "IALAB"
$iaCluster = Get-Cluster -Name $cluster
$iaServers = @(Get-VMHost -Location $iaCluster)

$portmap = @{}
$portmap["vmnic0"] = 'Yellow-113'
$portmap["vmnic1"] = 'Green-10'
$portmap["vmnic2"] = 'Blue-13'
$portmap["vmnic3"] = 'Orange-10'
$portmap["vmnic4"] = 'Management Network'

$iaServers | ForEach-Object {
	$vmHost = $_
	$vmHostname = $vmHost.Name
	Write-Host "Checking $vmHostname..."
	#$ports = @($_ | Get-VirtualPortGroup)
	#$ports | ForEach-Object {
	#	$name = $_.Name
	#	$port = (Get-VirtualSwitch -VMHost $vmHost -Name $_.VirtualSwitchName).NIC
	#	if ($portmap[$port] -ne $name) {
	#		Write-Host "     " `[($portmap[$port])`] " expected, " [ $name ] " given."
	#	}
	#}


	#$_ | Remove-Datastore -Datastore "Software ISOs" -Confirm:$false
	#$_ | Remove-Datastore -Datastore "vSpace-msia" -Confirm:$false
	
	$_ | New-Datastore -Nfs -NfsHost $netapp -Path "/vol/vspace/msia/CCDC" -Name "CCDC" -Confirm:$false
	#$_ | New-Datastore -Nfs -NfsHost $netapp -Path "/vol/vspace/msia/Gold Images and Templates" -Name "MSIA-ClassPrep" -Confirm:$false
	#$_ | New-Datastore -Nfs -NfsHost $netapp -Path "/vol/vspace/msia/Classroom VMs" -Name "MSIA-ClassroomVMs" -Confirm:$false
	#$_ | New-Datastore -Nfs -NfsHost $netapp -Path "/vol/vspace/msia/ISOs" -Name "MSIA-ISOs" -ReadOnly:$true -Confirm:$false
	
	#break
}