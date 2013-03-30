# Connect to the vsphere server
$server = connect-viserver "vsphere.ccs.neu.edu"

# IP Address 129.10.121.XXX, $ipStart is XXX
$btIpStart = 20#100
$win7IpStart = 60#120

# Nat rules
$btPortStart = 10020#101
$win7PortStart = 10060#121

# The Name of the Template used to make the VMs, minus the numbers
$btTemplateName = "ia5010-spring2012-bt"
$win7TemplateName = "ia5010-spring2012-win"

$stream = [System.IO.StreamWriter] "Z:\.WIN_PROFILE\Desktop\ia5010_dhcp_spring.txt"

# Get all the VMs in vsphere that share the Template name and grab their mac address
Get-VM -Name "$btTemplateName*" | ForEach-Object {
	
	# Get the number of the VM currently selected
	$vmId = $_.Name -replace $btTemplateName, ""
	$vmId = [int]$vmId
	
	#if ($vmId -gt 28) {
		# Grab the Network Adapter
		$vmAdapter = Get-NetworkAdapter -VM $_
		
		# Grab the Mac Address from the Adapter
		$vmEthernet = $vmAdapter.MacAddress
		
		# Remove the fall part for the hostname
		$dnsName = $_.Name -replace "spring2012-", ""
		
		# The last part of the ip address is the start ip plus the machine id
		$ip = $btIpStart + $vmId#($vmId - 28)
		
		# Generate the pfsense xml information
		$stream.WriteLine("<staticmap>")
		$stream.WriteLine("	<mac>$vmEthernet</mac>")
		$stream.WriteLine("	<ipaddr>10.0.10.$ip</ipaddr>")
		$stream.WriteLine("	<hostname>$dnsName</hostname>")
		$stream.WriteLine("	<descr/>")
		$stream.WriteLine("	<netbootfile/>")
		$stream.WriteLine("</staticmap>")
	#}
}

# Get all the VMs in vsphere that share the Template name and grab their mac address
Get-VM -Name "$win7TemplateName*" | ForEach-Object {
	
	# Get the number of the VM currently selected
	$vmId = $_.Name -replace $win7TemplateName, ""
	
	$vmId = [int]$vmId
	
	#if ($vmId -gt 28) {
		# Grab the Network Adapter
		$vmAdapter = Get-NetworkAdapter -VM $_
		
		# Grab the Mac Address from the Adapter
		$vmEthernet = $vmAdapter.MacAddress
		
		# Remove the fall part for the hostname
		$dnsName = $_.Name -replace "spring2012-", ""
		
		# The last part of the ip address is the start ip plus the machine id
		$ip = $win7IpStart + $vmId#($vmId - 28)
		
		# Generate the pfsense xml information
		$stream.WriteLine("<staticmap>")
		$stream.WriteLine("	<mac>$vmEthernet</mac>")
		$stream.WriteLine("	<ipaddr>10.0.10.$ip</ipaddr>")
		$stream.WriteLine("	<hostname>$dnsName</hostname>")
		$stream.WriteLine("	<descr/>")
		$stream.WriteLine("	<netbootfile/>")
		$stream.WriteLine("</staticmap>")
	#}
}

$stream.close()