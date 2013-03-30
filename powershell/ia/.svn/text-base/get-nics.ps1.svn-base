# Connect to the vsphere server
$server = connect-viserver "vsphere.ccs.neu.edu"

# IP Address 129.10.121.XXX, $ipStart is XXX
$ipStart = 150

# The Name of the Template used to make the VMs, minus the numbers
$vmTemplateName = "ia5130-fall2011-vm3"

# Get all the VMs in vsphere that share the Template name and grab their mac address
Get-VM -Name "$vmTemplateName*" | ForEach-Object {
	
	# Get the number of the VM currently selected
	$vmId = $_.Name -replace $vmTemplateName, ""
	
	# Grab the Network Adapter
	$vmAdapter = Get-NetworkAdapter -VM $_
	
	# Grab the Mac Address from the Adapter
	$vmEthernet = $vmAdapter.MacAddress
	
	# Remove the fall part for the hostname
	$dnsName = $_.Name -replace "fall2011-", ""
	
	# The last part of the ip address is the start ip plus the machine id
	$ip = $ipStart + $vmId
	
	# Generate the pfsense xml information
	Write-Host "<staticmap>"
	Write-Host "	<mac>$vmEthernet</mac>"
	Write-Host "	<ipaddr>129.10.121.$ip</ipaddr>"
	Write-Host "	<hostname>$dnsName</hostname>"
	Write-Host "	<descr/>"
	Write-Host "	<netbootfile/>"
	Write-Host "</staticmap>"
}