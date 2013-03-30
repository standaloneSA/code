$server = connect-viserver "vsphere.ccs.neu.edu"

# Get the original VM for grabbing cluster information
$vmPrime = Get-VM "ia5130-gold-20110809"

# Get the first cloned VM for its folder
$vmCloned = Get-VM "ia5130-fall2011-vm1"

# Grab the template that we are deploying the classroom VMs from
$vmTemplate = Get-Template "ia5130-gold-20110809-template"

# Grab the cluster that the original VM is a member of
$vmCluster = $vmPrime | Get-Cluster

# Get the datastore
$vmDatastore = Get-Datastore -Name "narnia-nfs"

# Get the Resource Pool
$vmResourcePool = $vmCloned | Get-ResourcePool #-VM "ia5130-gold-20110809"

# Get the Folder
$vmFolder = $vmCloned.Folder

# Number of VMs to Create
$vmNum = 3

# Starting Index
$vmIndex = 35

# Name of the VMs to Create
$vmTemplateName = "ia5130-fall2011-vm"

# Loop N times to create hosts
$index = $vmIndex
While ($index -lt ($vmIndex + $vmNum)) {
	# Grab the least used Host in the cluster
	$vmHost = $vmCluster | Get-VMHost | Sort $_.CpuUsageMhz -Descending | Select -First 1
	
	# Name the machine using the template name
	$vmName = $vmTemplateName + $index
	Write-Host "Creating $vmName on $($vmHost.Name) in $($vmDatastore.Name)"
	
	# Create the VM
	$vmCreated = New-VM -RunAsync -Name $vmName -VMHost $vmHost -Template $vmTemplate -Datastore $vmDatastore -ResourcePool $vmResourcePool -Location $vmFolder

	# Increment index
	$index++
}


