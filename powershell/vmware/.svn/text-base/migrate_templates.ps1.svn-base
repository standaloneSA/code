$server = connect-viserver "classroomvc.ccs.neu.edu"

ForEach ($template in Get-Template) {
	Write-Host "Converting $template to vm"
	$vm = Set-Template -Template $template -ToVM
	Write-Host "Migrate $template to $datastore"
	Move-VM -VM $vm -Datastore (Get-Datastore 'vm-nfs') -Confirm:$false
	($vm | Get-View).MarkAsTemplate() | Out-Null
}