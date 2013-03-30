$server = connect-viserver "vsphere2.ccs.neu.edu"
Get-Datacenter | Get-VM | %{
	$vm = $_
	Get-Datastore -VM $vm | %{
		$vm.Name + "`t`t" + $_.Name
	}
} | where {$_ -match "vspace"}