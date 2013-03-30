# Variables
# Number of "Pods" to create
$vmPods = 60# Subtract 1 for the baseline pod
$vmIndex = 2 # Add 1 to account for the baseline pod

# Connect to the vsphere server
$server = connect-viserver "classroomvc.ccs.neu.edu"

$vmTmplName = @()
$vmTmplName += "ia5130-centos"

$vmTmpl = @()
$vmTmpl += (Get-Template "ia5130-centos-LCMASTER-nimbletest")

# Get the cluster
$vmCluster = Get-Cluster "Teaching"

# Get the datastore
$vmDatastore = (Get-Datastore -Name "test1" | Get-View)

# Get the Resource Pool
$vmResourcePool = ($vmCluster | Get-ResourcePool "ia5130-fall-2012-studentvms" | Get-View)

# Loop N times to create hosts
$index = $vmIndex
While ($index -lt ($vmIndex + $vmPods)) {
	# Grab the least used Host in the cluster
	$vmHost = get-vmhost sultana.ccs.neu.edu | Get-View
	#$vmHost = ($vmCluster | Get-VMHost | Sort $_.CpuUsageMhz -Descending | Select -First 1 | Get-View)
	Write-Host "Creating VMs for Pod $index..."	
	for ($i=0; $i -lt $vmTmpl.length; $i++) {
		$vmName = $vmTmplName[$i] + $index
		Write-Host "... Creating $vmName"
		$vm = $vmTmpl[$i] | Get-View
		$cloneFolder = $vm.parent
		$cloneSpec = new-object Vmware.Vim.VirtualMachineCloneSpec
		$cloneSpec.Location = new-object Vmware.Vim.VirtualMachineRelocateSpec
		$cloneSpec.Location.Pool = $vmResourcePool.MoRef
		$cloneSpec.Location.host = $vmHost.MoRef
		$cloneSpec.Location.Datastore = $vmDatastore.MoRef
		$cloneSpec.Snapshot = $vm.Snapshot.CurrentSnapshot
		#$cloneSpec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::createNewChildDiskBacking
		$cloneSpec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::moveAllDiskBackingsAndAllowSharing
		$cloneSpec.powerOn = $false
		$vm.CloneVM_Task( $cloneFolder, $vmName, $cloneSpec ) #Nonblocking
	}
	$index++
}
