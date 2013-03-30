# Variables
# Number of "Pods" to create
$vmPods = 15#4 # Subtract 1 for the baseline pod
$vmIndex = 14 # Add 1 to account for the baseline pod

# Connect to the vsphere server
$server = connect-viserver "vsphere.ccs.neu.edu"

$vmTmplName = "ia5150-sp2012-oncampus-bt", "ia5150-sp2012-oncampus-centos", "ia5150-sp2012-oncampus-2k3win", "ia5150-sp2012-oncampus-winxp"

$vmTmpl = @()
$vmTmpl += (Get-Template "ia5150-backtrack5-LCMASTER-20120214")
$vmTmpl += (Get-Template "ia5150-centos5.5-LCMASTER-20120214")
$vmTmpl += (Get-Template "ia5150-win2k3-LCMASTER-20120214")
$vmTmpl += (Get-Template "ia5150-winxpsp2-LCMASTER-20120214")

# Get the cluster
$vmCluster = Get-Cluster "Teaching"

# Get the datastore
$vmDatastore = (Get-Datastore -Name "narnia-nfs" | Get-View)

# Get the Resource Pool
$vmResourcePool = ($vmCluster | Get-ResourcePool "ia5150-spring-2012-oncampus" | Get-View)

# Loop N times to create hosts
$index = $vmIndex
While ($index -lt ($vmIndex + $vmPods)) {
	# Grab the least used Host in the cluster
	$vmHost = ($vmCluster | Get-VMHost | Sort $_.CpuUsageMhz -Descending | Select -First 1 | Get-View)
	Write-Host "Creating VMs for Pod $index..."	
	for ($i=0; $i -lt $vmTmpl.length; $i++) {
		$vmName = $vmTmplName[$i] + $index
		Write-Host "... Creating $vmName"
		$vm = $vmTmpl[$i] | Get-View
		$cloneFolder = $vm.parent
		$cloneSpec = new-object Vmware.Vim.VirtualMachineCloneSpec
		$cloneSpec.Location = new-object Vmware.Vim.VirtualMachineRelocateSpec
		$cloneSpec.Location.Pool = $vmResourcePool.MoRef
		$cloneSpec.Location.host = $vmHost.MoRef #($vmTmpl[$i] | get-vmhost | get-view).MoRef
		$cloneSpec.Location.Datastore = $vmDatastore.MoRef
		$cloneSpec.Snapshot = $vm.Snapshot.CurrentSnapshot
		$cloneSpec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::createNewChildDiskBacking
		$cloneSpec.powerOn = $false
		#$vm.CloneVM( $cloneFolder, $vmName, $cloneSpec ) #Blocking
		$vm.CloneVM_Task( $cloneFolder, $vmName, $cloneSpec ) #Nonblocking
		#$vm2 = Get-VM $vmName
		#Get-HardDisk -VM $vm2 | Set-HardDisk -Persistence "IndependentNonPersistent" -Confirm $false
	}
	$index++
}