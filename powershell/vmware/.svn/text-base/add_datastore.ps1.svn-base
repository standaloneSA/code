$server = connect-viserver "classroomvc.ccs.neu.edu"
$vmCluster = Get-Cluster "Teaching"
ForEach ($vmHost in $vmCluster | Get-VMHost) 
{ 
    $vmHost | New-Datastore -Nfs -Name "backedup-nfs" -NFSHost "morpork-200.ccs.neu.edu" -Path "/vol/esxistorage/backedupvms"
	$vmHost | New-Datastore -Nfs -Name "notbackedup-nfs" -NFSHost "morpork-200.ccs.neu.edu" -Path "/vol/esxistorage/notbackedupvms"
}