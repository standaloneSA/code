# Connect to the vsphere server
$server = connect-viserver "classroomvc.ccs.neu.edu"

$outputFile = "Z:\.WIN_PROFILE\Desktop\ia5130_dhcp_fall2012.txt"
$ipPrefix = "129.10.121"
$numPods = 60 # Number of Pods to create rules for
$numVms = 1 # Number of VMs per Pod
$ipPostfix = 100

$vmClassName = "ia5130"
$vmClassSem = "f12"
$vmTmplName = "centos"

# Open a stream for writing
$stream = [System.IO.StreamWriter] $outputFile

# The Name of the Template used to make the VMs, minus the numbers
$vmTemplateName = $vmClassName + "-" + $vmClassSem + "-" + $vmTmplName
	
# Get all the VMs in vsphere that share the Template name and grab their mac address
Get-VM -Name "$vmTemplateName*" | ForEach-Object {
	# Get the number of the VM currently selected
	$vmId = $_.Name -replace $vmTemplateName, ""
	$vmId = [int]$vmId

	$vmAdapter = Get-NetworkAdapter -VM $_
	
	# Grab the Mac Address from the Adapter
	$vmEthernet = $vmAdapter.MacAddress
	
	# Remove the fall part for the hostname
	$dnsName = $_.Name -replace $vmClassSem + "-", ""
	
	# The last part of the ip address
	$ip = [int]$ipPostfix + $vmId
	
	# Generate the pfsense xml information
	$stream.WriteLine("<staticmap>")
	$stream.WriteLine("	<mac>$vmEthernet</mac>")
	$stream.WriteLine("	<ipaddr>$ipPrefix.$ip</ipaddr>")
	$stream.WriteLine("	<hostname>$dnsName</hostname>")
	$stream.WriteLine("	<descr/>")
	$stream.WriteLine("	<netbootfile/>")
	$stream.WriteLine("</staticmap>")
}
$stream.close()