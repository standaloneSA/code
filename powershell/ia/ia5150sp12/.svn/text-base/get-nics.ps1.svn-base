# Connect to the vsphere server
$server = connect-viserver "vsphere.ccs.neu.edu"

$outputFile = "Z:\.WIN_PROFILE\Desktop\ia5150_dhcp_spring.txt"
$ipPrefix = "10.0.10"
$numPods = 15 # Number of Pods to create rules for
$numVms = 4 # Number of VMs per Pod
$ipPodPostfix = 10 # Starting IP to go up from
$ipPodPostfixSkip = 10 # Number of IPs to jump per pod
$natPodStart = 10001 # Base NAT port

$vmClassName = "ia5150"
$vmClassSem = "spring2012"
$vmTmplName = "bt", "centos", "2k3win", "winxp"

# Open a stream for writing
$stream = [System.IO.StreamWriter] $outputFile

# Loop through the templates
for ($i=0; $i -lt $vmTmplName.length; $i++) {
	# The Name of the Template used to make the VMs, minus the numbers
	$vmTemplateName = $vmClassName + "-" + $vmClassSem + "-" + $vmTmplName[$i]
	
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
		$ip = $i + (($vmId - 1) * $ipPodPostfixSkip) + $ipPodPostfix
		
		# Generate the pfsense xml information
		$stream.WriteLine("<staticmap>")
		$stream.WriteLine("	<mac>$vmEthernet</mac>")
		$stream.WriteLine("	<ipaddr>$ipPrefix.$ip</ipaddr>")
		$stream.WriteLine("	<hostname>$dnsName</hostname>")
		$stream.WriteLine("	<descr/>")
		$stream.WriteLine("	<netbootfile/>")
		$stream.WriteLine("</staticmap>")
	}
}
$stream.close()

$stream = [System.IO.StreamWriter] "Z:\.WIN_PROFILE\Desktop\ia5150_nat.txt"
$index = 0
While ($index -lt $numPods) {
	$natPort = $natPodStart + $index
	$natTarget = ($index * $ipPodPostfixSkip) + $ipPodPostfix
	$stream.WriteLine("	<rule>")
	$stream.WriteLine("		<source>")
	$stream.WriteLine("			<any/>")
	$stream.WriteLine("		</source>")
	$stream.WriteLine("		<destination>")
	$stream.WriteLine("			<network>wanip</network>")
	$stream.WriteLine("			<port>$natPort</port>")
	$stream.WriteLine("		</destination>")
	$stream.WriteLine("		<protocol>tcp</protocol>")
	$stream.WriteLine("		<target>10.0.10.$natTarget</target>")
	$stream.WriteLine("		<local-port>5901</local-port>")
	$stream.WriteLine("		<interface>wan</interface>")
	$stream.WriteLine("		<descr/>")
	$stream.WriteLine("	</rule>")
	$index++
}
$stream.close()