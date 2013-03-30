# create-vms.ps1

<# 
This script is used to create a new set of pods. It should be suffienciently abstracted
to work for any class. 

#> 


$viServer = "classroomvc.ccs.neu.edu"

#### Get things connected and ready to go ####
# Set the InvalidCertificateAction to warn so that future PowerCLIs don't
# automatically fail to connect us.
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Scope Session -confirm:$false | out-null

# test to see if we're connected before we, you know, connect
if ($DefaultVIServers -eq $null) {
        write-host "Connecting to $viServer"
        Connect-VIServer $viServer | out-null
} else {
        if (@($DefaultVIServers).length -gt 1) {
                # There's the possibility that we make some assumptions that the VI host isn't an array...
                # There are various modes available through Set-PowerCLIConfiguration that would allow
                # us to mandate only one connection, but there are set to be changes in the next ver of
                # powerCLI (currently at 5.1 as I write this)
                # -MS 20130204
                write-host "Sorry, this script only supports being connected to a single host."
                write-host "It appears that you are connected to" @($DefaultVIServers).length
                write-host "Exiting now..."
                exit
        }
        write-host "Already connected to" $DefaultVIServers
        $continue = read-host  "Continue while using this server? (y/n): "
        if ($continue -ne "y") {
                exit
        } else {
                $NODISASSEMBLE = 1
                $viServer = $DefaultVIServers
        }
}
#### We should now be connected, stable, and ready to rock and roll ####


### Important ###
# The name format of the gold images must be: 
#
# 		classcode-OSdesc-gold-date
#
# so for instance
#
# 		ia5150-backtrack5-gold-20130206
#

$classCode 		= "ia5150"
$semester 		= "spring-2013"
$pods				= "1"
$targetDS 		= Get-Datastore "vm-nfs"
$vmCluster 		= Get-Cluster "Teaching"
$resourcePool 	= "$classCode-$semester"


# See comments after
$sourceGoldVMArray = @{
	"backtrack5" 	= @{ "date" = "20130206" }
	"centos5.5" 	= @{ "date" = "20130129" }
	"win2k3" 		= @{ "date" = "20130129" }
	"winxpsp2" 		= @{ "date" = "20130129" }
}
# Above is the array that we'll be using to refer to the gold images
# The full data structure will look like this once it's populated: 
# $sourceGoldVMArray = @{
# 		"OSdesc" 			= @{
# 			"date"			= "yyyymmdd"
# 			"vmGold"			= vmObj
# 			"vmTemplate"	= TemplateObj
# 			"vmRP"			= ResourcePoolObj
# 			"myFolder"		= FolderIDObj
# 			"parentFolder"	= FolderIDObj
# 			"cloneFolder"	= FolderIDObj
# 		}
# }
# But in the beginning, we manually provide the date and then programmatically 
# determine the rest.


# Basically, we are looping through the OS hashtable elements above. We do one entire loop for
# "backtrack5", for instance, then through "centos5.5", or whatever comprises the keys to
# $sourceGoldVMArray above
$sourceGoldVMArray.keys | forEach-Object {
	$thisGoldInst = $sourceGoldVMArray["$_"]
	$vmGoldName = "$classCode-$_-gold-{0}" -f $thisGoldInst["date"]
	$thisGoldInst["vmGold"] = Get-VM $vmGoldName
	if ( $thisInstance["vmGold"].id -eq "$null" ) { 
		Write-Host "Error addressing $_"
		exit
	}
	
	# Get the Folder IDs for everything
	$thisGoldInst["myFolder"] 		= Get-Folder -id ($thisGoldInst["vmGold"] | Get-View).Parent
	$thisGoldInst["parentFolder"] 	= Get-Folder -id ($thisGoldInst["myFolder"] | Get-View).Parent
	
	# Iterate through the several child folders of our parent
	# ... in other words, the folders at the same level as the one that holds the gold VM
	# We're looking for on that says "Classroom", because that's where the clones will go
	($thisGoldInst["parentFolder"] | Get-View).ChildEntity | ForEach-Object { 
		$thisFolder = Get-Folder -id "$_"
		if ($thisFolder.Name -eq "Classroom") { 
			$thisGoldInst["cloneFolder"] = $thisFolder
		}
	}
	 
	# By default, the cloned VMs live in the same resource pool as the gold images. 
	# This way, though, if the RP needs to be different, it can be defined above in the
	# initial creation of the array
	if ($thisGoldInst["vmRP"] -ne $null) { 
		$tmpRP = Get-ResourcePool -name $thisGoldInst["vmRP"]
		if ($tmpRP.GetType().FullName -ne "VMware.VimAutomation.Client20.ResourcePoolImpl") { 
			write-host "Error setting specified Resource Pool for the following entry: $thisGoldInst"
			write-host "Using default of $resourcePool"
			$thisGoldInst["vmRP"] = Get-ResourcePool -name $resourcePool
		} else { 
			$thisGoldInst["vmRP"] = $tmpRP
		}
	} else { 
		$thisGoldInst["vmRP"] = Get-ResourcePool -name $resourcePool
	}

	# We'll put it on the one with the lowest memory usage. This isn't perfect (it should be biggest free)
	$targetVMHost = $vmCluster | Get-VMHost | sort $_.MemoryUsageMB -Descending | Select -First 1 | Get-View

	# Set up the clonespec for the clone-which-will-become-the-template
	$cloneSpec = new-object VMware.Vim.VirtualMachineCloneSpec
	$cloneSpec.Location = new-object Vmware.Vim.VirtualMachineRelocateSpec
	$cloneSpec.Location.Pool = $thisGoldInst["vmRP"].MoRef
	$cloneSpec.Location.host = $targetVMHost.MoRef
	$cloneSpec.Location.Datastore = $targetDS.MoRef

	# We want to mark the templates that we create today
	$today = get-date -format yyyyMMdd
		
	### The template has to be created from a snapshot (well, not _has_ to, but it's best practice)
	New-snapshot -vm $thisGoldInst["vmGold"] -name "Automated_$today"
	$cloneSpec.Snapshot = ($thisGoldInst["vmGold"] | Get-View).Snapshot.CurrentSnapshot

	# This basically copies over a disk and doesn't refer to the original 
	# See http://www.vmware.com/support/developer/vc-sdk/visdk400pubs/ReferenceGuide/vim.vm.RelocateSpec.DiskMoveOptions.html
	$cloneSpec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::createNewChildDiskBacking
	$cloneSpec.powerOn = $false

	$thisGoldInst["vmTemplate"] = Get-Template "$classCode-$_-LCMASTER-$today"
	Write-Host "Creating LCMASTER for $_"
	
	# We want it to be blocking so we're sure that it's done before we move on...
	($thisGoldInst["vmGold"] | Get-View).cloneVM($thisGoldInst["cloneFolder"], "$classCode-$_-$semester-LCMASTER-$today", $cloneSpec )

	# Done with the clone, we can remove the snapshot now
	Get-Snapshot -vm $thisGoldInst["vmGold"] -name "Automated_$today" | Remove-Snapshot -confirm:$false

	# Chris N started the idea of turning the LCMASTER (Link Clone Master) into a template. 
	# It's a good idea, because it can't be turned on and consume resources if the instructor
	# screws up and tries to start it. 
	Write-Host "LCMASTER Has been cloned. Snapshotting & turning into a template now"
	New-Snapshot -vm $thisGoldInst["vmTemplate"] -name "Base Snapshot"
 	($thisGoldInst["vmTemplate"] | Get-View).MarkAsTemplate()

	Write-Host "OK, done with the LCMASTER. Now creating instances...."
	for ($i=0; $i -lt $pods; $i++) { 
		$vmName = "$classCode-$semester-$_-$i"
		write-host "Making $vmName"
		$targetVMHost = $vmCluster | Get-VMHost | sort $_.MemoryUsageMB -Descending | Select -First 1 | Get-View
		$cloneSpec.Snapshot = ($thisGoldInst["vmTemplate"] | Get-View).Snapshot.CurrentSnapshot
		($thisGoldInst["vmTemplate"] | Get-View).cloneVM( $thisGoldInst["cloneFolder"], $vmName, $cloneSpec)
		Get-HardDisk -VM $vmName | Set-HardDisk -Persistence "IndependentNonPersistent" -Confirm:$false
	}
	
	Write-Host "Done. Here's the object:"
	$thisGoldInst


}


