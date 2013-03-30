﻿$server = connect-viserver "vsphere.ccs.neu.edu"

#$vm = Get-VM "ChrisN-Test1-Master" | Get-View
$vm = Get-Template "ChrisN-Test1-Master" | Get-View
$cloneFolder = $vm.parent


for ($i=1; $i -lt 2; $i++) {
	$cloneName = "ChrisN-LinkedClone-$i"
	$cloneSpec = new-object Vmware.Vim.VirtualMachineCloneSpec
	$cloneSpec.Location = new-object Vmware.Vim.VirtualMachineRelocateSpec  # required

	$cloneSpec.Location.Pool = (get-cluster "Teaching" | get-resourcepool "ChrisN" | get-view).MoRef
	#$cloneSpec.Location.Host = (get-vm "ChrisN-Test1-Master" | get-vmhost | get-view).MoRef
	#$cloneSpec.Location.Host = (get-template "ChrisN-Test1-Master" | get-vmhost | get-view).MoRef
	$cloneSpec.Location.host = (get-cluster "Teaching" | Get-VMHost | Sort $_.CpuUsageMhz -Descending | Select -First 1 | Get-View).MoRef
	$cloneSpec.Location.Datastore = (Get-Datastore -Name "narnia-nfs" | get-view).MoRef #(get-datastore -vm "ChrisN-Test1-Master" | get-view).MoRef

	$cloneSpec.Snapshot = $vm.Snapshot.CurrentSnapshot

	#This option requires that a snapshot that already exists on the VM, 
	#and that $cloneSpec.Snapshot has been set to it. Since this option 
	#does not clone from a VM’s current state but from one of its snapshots, 
	#the clone will not necessarily contain the current state of the source 
	#VM (unless you have not powered on the source VM since taking the snapshot). 
	#This option is the fastest way to create a clone.
	$cloneSpec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::createNewChildDiskBacking

	$cloneSpec.powerOn = $true

	$vm.CloneVM( $cloneFolder, $cloneName, $cloneSpec ) #Blocking
}

#$vm2 = Get-VM $cloneName
#Get-HardDisk -VM $vm2 | Set-HardDisk -Persistence "IndependentNonPersistent" -Confirm $false
#$vm.CloneVM_Task( $cloneFolder, $cloneName, $cloneSpec ) #Nonblocking