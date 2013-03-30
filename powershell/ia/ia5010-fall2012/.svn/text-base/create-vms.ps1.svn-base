# Variables
# Number of "Pods" to create
$vmPods = 49#49# Subtract 1 for the baseline pod
$vmIndex = 2 # Add 1 to account for the baseline pod

# Connect to the vsphere server
$server = connect-viserver "classroomvc.ccs.neu.edu"

$vmTmplName = "ia5010-f12-bt", "ia5010-f12-winxp"

$vmTmpl = @()
$vmTmpl += (Get-Template "ia5010-bt-LCMASTER-20120904")
$vmTmpl += (Get-Template "ia5010-winxp-LCMASTER-20120904")

# Get the cluster
$vmCluster = Get-Cluster "Teaching"

# Get the datastore
$vmDatastore = (Get-Datastore -Name "vm-nfs" | Get-View)

# Get the Resource Pool
$vmResourcePool = ($vmCluster | Get-ResourcePool "ia5010-fall-2012-studentvms" | Get-View)

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