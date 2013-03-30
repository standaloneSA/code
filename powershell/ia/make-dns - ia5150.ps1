# Connect to the vsphere server
$server = connect-viserver "vsphere.ccs.neu.edu"

# The Name of the Template used to make the VMs, minus the numbers
$vmTemplateName = "ia5130-fall2011-vm"

$stream = [System.IO.StreamWriter] "Z:\.WIN_PROFILE\Desktop\ia5150_hb.txt"

# Get all the VMs in vsphere that share the Template name and grab their mac address
Get-VM -Name "$vmTemplateName*" | ForEach-Object {
	
	# Get the number of the VM currently selected
	$vmip = $_.Guest.IPAddress[0]
	$ip = $vmip.Split(' ')[0]
	#$ip = [String]$_.Guest.IPAddress
	
	# Grab the Network Adapter
	$vmAdapter = Get-NetworkAdapter -VM $_
	
	# Grab the Mac Address from the Adapter
	$vmEthernet = $vmAdapter.MacAddress
	
	# Remove the fall part for the hostname
	$dnsName = $_.Name -replace "fall2011-", ""
	
	# Generate the hostbase information
	$stream.WriteLine("-------------------------------------------------------------------------")
	$stream.WriteLine("Hostname:       $dnsName.ccs.neu.edu")
	$stream.WriteLine("Primary:        yes")
	$stream.WriteLine("Cname:")
	$stream.WriteLine("Architecture:   intel")
	$stream.WriteLine("Model:          virtual")
	$stream.WriteLine("OS:")
	$stream.WriteLine("Version:")
	$stream.WriteLine("IP number:      $ip")
	$stream.WriteLine("Ethernet:")
	$stream.WriteLine("Port:           virtual")
	$stream.WriteLine("Bootserver:     none")
	$stream.WriteLine("Xdmserver:      none")
	$stream.WriteLine("Cpu:            virtual")
	$stream.WriteLine("Memory:         virtual")
	$stream.WriteLine("Display:        virtual")
	$stream.WriteLine("User:           ia5150")
	$stream.WriteLine("Access:         ia5150")
	$stream.WriteLine("Newnet:         yes")
	$stream.WriteLine("Room:")
	$stream.WriteLine("Macrouter:      no")
	$stream.WriteLine("Rsh:            no")
	$stream.WriteLine("Nfs:            no")
	$stream.WriteLine("Backup:         no")
	$stream.WriteLine("DHCP:           no")
	$stream.WriteLine("Serial:         virtual")
	$stream.WriteLine("Contract:       virtual")
	
}
$stream.close()