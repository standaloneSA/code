
$hostToFix = get-vmhost magrathea.ccs.neu.edu
$hostView = $hostToFix | Get-View

$vSwitch = $hostToFix | get-virtualswitch -name vSwitch1

foreach ( $virtPG in ( $vSwitch | get-VirtualPortGroup ) ) { 
	if ( $virtPG.name -ne "iSCSI" ) { 
		$oldName = "$virtPG"
		write-host $oldName

	}
}


