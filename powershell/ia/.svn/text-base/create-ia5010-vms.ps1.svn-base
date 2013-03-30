$server = connect-viserver "vsphere.ccs.neu.edu"

# Get the original VM for grabbing cluster information
$vmBt = Get-VM "ia5010-backtrack-gold-20111201"#"ia5010-backtrack-gold-20110915"
$vmWin = Get-VM "ia5010-winxp-gold-20111201"#"ia5010-win7-gold-20110914"

# Get the first cloned VM for its folder
$vmBtCloned = Get-VM "ia5010-spring2012-bt1"#"ia5010-fall2011-bt1"
$vmWinCloned = Get-VM "ia5010-spring2012-win1"#"ia5010-fall2011-win1"

# Grab the template that we are deploying the classroom VMs from
$btTemplate = Get-Template "ia5010-backtrack-template-20120113" #"ia5010-backtrack-template-20110927"
$winTemplate = Get-Template "ia5010-winxp-template-20120112" #"ia5010-win7-template-20110929"

# Grab the cluster that the original VM is a member of
$vmCluster = $vmWin | Get-Cluster

# Get the datastore
$vmDatastore = Get-Datastore -Name "narnia-nfs"

# Get the Resource Pool
$vmResourcePool = $vmWinCloned | Get-ResourcePool

# Get the Folder
$vmFolder = $vmWinCloned.Folder

# Number of VMs to Create
$vmNum = 21

# Starting Index
$vmIndex = 2

# Name of the VMs to Create
$btTemplateName = "ia5010-spring2012-bt"
$winTemplateName = "ia5010-spring2012-win"

# Loop N times to create hosts
$index = $vmIndex
While ($index -lt ($vmIndex + $vmNum)) {
	# Grab the least used Host in the cluster
	$vmHost = $vmCluster | Get-VMHost | Sort $_.CpuUsageMhz -Descending | Select -First 1
	
	# Name the machine using the template name
	$btName = $btTemplateName + $index
	$winName = $winTemplateName + $index
	
	Write-Host "Creating $btName and $winName on $($vmHost.Name) in $($vmDatastore.Name)"
	
	# Create the VM
	$btCreated = New-VM -RunAsync -Name $btName -VMHost $vmHost -Template $btTemplate -Datastore $vmDatastore -ResourcePool $vmResourcePool -Location $vmFolder
	$winCreated = New-VM -RunAsync -Name $winName -VMHost $vmHost -Template $winTemplate -Datastore $vmDatastore -ResourcePool $vmResourcePool -Location $vmFolder

	# Increment index
	$index++
}