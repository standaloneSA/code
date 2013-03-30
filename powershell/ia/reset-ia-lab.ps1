Function WaitForTask($taskref) {
	$task = Get-View $taskref
	while ($task.Info.State -eq "running" -or $task.Info.State -eq "queued") {
		Start-Sleep -Seconds 1
		$task = Get-View $taskref
	}
}

Function GetVMsInDatastore($datastore,$extension) {
	foreach($dsi in Get-Datastore $datastore) {
		$ds = Get-Datastore -Name $dsi | %{Get-View $_.Id}
		$searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
		$searchSpec.matchpattern = "*$extension"
		$dsBrowser = Get-View $ds.browser
		$dsBrowser.SearchDatastoreSubFolders("[" + $ds.Summary.Name + "]", $searchSpec) | where {$_.FolderPath -notmatch ".snapshot"} | %{$_.FolderPath + ($_.File | select Path).Path}
	}
}

$server = connect-viserver "ialabvsphere.ccs.neu.edu"#"vsphere1.ccs.neu.edu"
$gold = "Gold Images and Templates"
$datacenter = "MSIA"
$cluster = "IALab"


#debug mode variable
$WhatIfPreference = $true
$ConfirmPreference = $true


$iaCluster = Get-Cluster -Name $cluster
$iaServers = @(Get-VMHost -Location $iaCluster)
$iaTemplates = @("Test Machine Template", "Test Machine 2 Template", "Test Machine 3 Template")


# Check for templates and gold images that may already exist, remove them from the esx servers
Get-VM -Location (Get-Datacenter -Name $datacenter | Get-Folder -Name $gold) | ForEach-Object {
	$name = $_.Name
	#Get-VM $_ | Remove-VM
}
Get-Template -Location (Get-Datacenter -Name $datacenter | Get-Folder -Name $gold) | ForEach-Object {
	$name = $_.Name
	#Get-Template $_ | Remove-Template
}

# Remove the virtual machines that exist on the server and delete them from inventory
Get-VM -Location (Get-Datacenter -Name $datacenter | Get-Folder -Name "IA Lab*") | ForEach-Object { #iaservers if adding a new esx host
	$name = $_.Name
	#Get-VM $_ | Remove-VM -DeletePermanently
}


# Check for existing machines in the Classroom Datastore
$localVMs = GetVMsInDatastore "LocalDisk*" ".vmx"
$classVMs = GetVMsInDatastore "MSIA-ClassroomVMs" ".vmx"
$prepVMs = GetVMsInDatastore "MSIA-ClassPrep" ".vmx"
$prepTemplates = GetVMsInDatastore "MSIA-ClassPrep" ".vmtx"

foreach($vm in $localVMs) {
	Write-Host $vm
}

foreach($vm in $classVMs) {
	Write-Host $vm
}

foreach($vm in $prepVMs) {
	Write-Host $vm
}

foreach($vm in $prepTemplates) {
	Write-Host $vm
}

#break

# Check the IA Lab folders for machines that still exist
foreach($datastore in Get-Datastore "*") {
	$ds = Get-Datastore -Name $datastore | %{Get-View $_.Id}
	$SearchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
	$SearchSpec.matchpattern = "*.vmx"
	$dsBrowser = Get-View $ds.browser
	$DatastorePath = "[" + $ds.Summary.Name + "]"
 
	# Find all .VMX file paths in Datastore, filtering out ones with .snapshot (Useful for NetApp NFS)
	$SearchResult = $dsBrowser.SearchDatastoreSubFolders($DatastorePath, $SearchSpec) | where {$_.FolderPath -notmatch ".snapshot" -and ($_.FolderPath -like "*IA Lab*" -or $_.FolderPath -like "*LocalDisk*")} | %{$_.FolderPath + ($_.File | select Path).Path}
	
	foreach($VMXFile in $SearchResult) {
		Write-Host $VMXFile
	}
	
	#Write-Output $ds.Summary.Name
}
#$view = Get-View (Get-Datacenter -Name $datacenter | Get-Folder -Name "IA Lab*")
#foreach ($vm in $view.Vm) {
#	$view2 = Get-View $vm
#	Write-Host $view2.Config.Files.VmPathName
#}



#break
# Import the templates used for building the IA machines
ForEach ($template in $iaTemplates) {
	# Pick a random host to dump the template on
	$vmHost = @(Get-VMHost -Location $iaCluster) | Get-Random
	$esx = $vmHost | Get-View
	# Grab the folder containing the templates
	$folder = Get-View (Get-Datacenter -Name $datacenter | Get-Folder -Name $gold).ID
	$vmtx = "[MSIA-ClassPrep]/$template/$template.vmtx"
	Write-Host "Adding template [$template]..."
	# Create the task to register the template and wait for it to complete
	WaitForTask($folder.RegisterVM_Task($vmtx,$template, $true, $null, $esx.MoRef))
}
break
Write-Host "Sleeping for 5 seconds"
Start-Sleep -Seconds 5

# We're done, clean up the templates
ForEach ($template in $iaTemplates) {
	Write-Host "Removing template [$template]..."
	Get-Template $template | Remove-Template
}


#$iaServers | ForEach-Object {
#	Write-Output $_.Name
# 	@($_ | Get-VM) | ForEach-Object {#
#		$name = $_.Name
#		Write-Output "Deleting $name"
#	}
#}

#$esx = Get-VMHost -Name "ialab8.ccs.neu.edu" | Get-View
# Get the original VM for grabbing cluster information
#$vmBt = Get-VM "ia5010-backtrack-gold-20110915"
#$vmWin7 = Get-VM "ia5010-win7-gold-20110914"

# Get the first cloned VM for its folder
#$vmBtCloned = Get-VM "ia5010-fall2011-bt1"
#$vmWin7Cloned = Get-VM "ia5010-fall2011-win1"

# Grab the template that we are deploying the classroom VMs from
#$btTemplate = Get-Template "ia5010-backtrack-template-20110927"
#$win7Template = Get-Template "ia5010-win7-template-20110929"

# Grab the cluster that the original VM is a member of
#$vmCluster = $vmWin7 | Get-Cluster

# Get the datastore
#$vmDatastore = Get-Datastore -Name "narnia-nfs"

# Get the Resource Pool
#$vmResourcePool = $vmWin7Cloned | Get-ResourcePool

# Get the Folder
#$vmFolder = $vmWin7Cloned.Folder

# Number of VMs to Create
#$vmNum = 17

# Starting Index
#$vmIndex = 29

# Name of the VMs to Create
#$btTemplateName = "ia5010-fall2011-bt"
#$win7TemplateName = "ia5010-fall2011-win"

# Loop N times to create hosts
#$index = $vmIndex
#While ($index -lt ($vmIndex + $vmNum)) {
	# Grab the least used Host in the cluster
#	$vmHost = $vmCluster | Get-VMHost | Sort $_.CpuUsageMhz -Descending | Select -First 1
	
	# Name the machine using the template name
#	$btName = $btTemplateName + $index
#	$win7Name = $win7TemplateName + $index
	
#	Write-Host "Creating $btName and $win7Name on $($vmHost.Name) in $($vmDatastore.Name)"
	
	# Create the VM
#	$btCreated = New-VM -RunAsync -Name $btName -VMHost $vmHost -Template $btTemplate -Datastore $vmDatastore -ResourcePool $vmResourcePool -Location $vmFolder
#	$win7Created = New-VM -RunAsync -Name $win7Name -VMHost $vmHost -Template $win7Template -Datastore $vmDatastore -ResourcePool $vmResourcePool -Location $vmFolder
#
	# Increment index
#	$index++
#}