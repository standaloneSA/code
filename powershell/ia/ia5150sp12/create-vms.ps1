# Variables
# Number of "Pods" to create
$vmPods = 4#4 # Subtract 1 for the baseline pod
$vmIndex = 13 # Add 1 to account for the baseline pod

# Connect to the vsphere server
$server = connect-viserver "vsphere.ccs.neu.edu"

# Grab the vms
$vmGold = Get-VM "ia5150-backtrack5-gold-20120203"#, Get-VM "ia5150-centos5.5-gold-20120203", Get-VM "ia5150-win2k3-gold-20120203", Get-VM "ia5150-winxpsp2-gold-20120203" 
$vmClon = Get-VM "ia5150-spring2012-bt1"#, Get-VM "ia5150-spring2012-centos1", Get-VM "ia5150-spring2012-2k3win1", Get-VM "ia5150-spring2012-winxp1"
$vmTmplName = "ia5150-spring2012-bt", "ia5150-spring2012-centos", "ia5150-spring2012-2k3win", "ia5150-spring2012-winxp"

$vmTmpl = @()
$vmTmpl += (Get-Template "ia5150-backtrack5-template-20120213")
$vmTmpl += (Get-Template "ia5150-centos5.5-template-20120213")
$vmTmpl += (Get-Template "ia5150-win2k3-template-20120213")
$vmTmpl += (Get-Template "ia5150-winxpsp2-template-20120213")

# Grab the cluster that the original VM is a member of
$vmCluster = $vmGold | Get-Cluster #[0]

# Get the datastore
$vmDatastore = Get-Datastore -Name "narnia-nfs"

# Get the Resource Pool
$vmResourcePool = $vmClon | Get-ResourcePool #[0]

# Get the Folder
$vmFolder = $vmClon.Folder #[0]

# Loop N times to create hosts
$index = $vmIndex
While ($index -lt ($vmIndex + $vmPods)) {
	# Grab the least used Host in the cluster
	$vmHost = $vmCluster | Get-VMHost | Sort $_.CpuUsageMhz -Descending | Select -First 1
	Write-Host "Creating VMs for Pod $index..."	
	for ($i=0; $i -lt $vmTmpl.length; $i++) {
		$vmName = $vmTmplName[$i] + $index
		Write-Host "... Creating $vmName on $($vmHost.Name) in $($vmDatastore.Name)"
		$vmCreated = New-VM -RunAsync -Name $vmName -VMHost $vmHost -Template $vmTmpl[$i] -Datastore $vmDatastore -ResourcePool $vmResourcePool -Location $vmFolder
	}
	$index++
}