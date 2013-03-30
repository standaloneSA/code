# Connect to the vsphere server
$server = connect-viserver "classroomvc.ccs.neu.edu"

$vmClassName = "ia5150"
$vmClassSem = "spring-2013"
$vmTmplName = "backtrack", "centos5.5", "win2k3", "winxpsp2"
$numPods = 45 # Number of Pods to create rules for
$numVms = 4 # Number of VMs per Pod
$ipPrefix = "10.0.10"

$outputFile = "Z:\IA-files\{0}_dhcp_{1}.xml" -f $vmClassName,$vmClassSem
echo "DHCP Output file: $outputFile"

# The Postfix is the last octet of the IP address, given $ipPrefix is a /24
$ipBTPostfix = 50 
$ipCentOSPostfix = 100
$ipWinXPPostfix = 150
$ipWin2k3Postfix = 200
$ipPostfix = $ipBTPostfix, $ipCentOSPostfix, $ipWinXPPostfix, $ipWin2k3Postfix
$ipPodPostfixSkip = 0 # Number of IPs to jump per pod

$natBTStart = 11000 # Base NAT port
$natCentOSStart = 12000
$natWinXPStart = 13000
$natWin2k3Start = 14000
$natStart = $natBTStart, $natCentOSStart, $natWinXPStart, $natWin2k3Start

# Open a stream for writing
$stream = [System.IO.StreamWriter] $outputFile
### Since we're writing the whole dhcpd section, we have to print the top part with the static mappings, too

# Lets make an array of arrays
$stream.Write("
	
<dhcpd>
	<lan>
		<enable/>
		<range>
			<from>10.0.10.240</from>
			<to>10.0.10.245</to>
		</range>
		<defaultleasetime/>
		<maxleasetime/>
		<netmask/>
		<failover_peerip/>
		<gateway/>
		<domain/>
		<domainsearchlist/>
		<denyunknown/>
		<ddnsdomain/>
		<tftp/>
		<ldap/>
		<next-server/>
		<filename/>
		<rootpath/>
		<numberoptions/>
")
#

$goldIP = 5
$brp = Get-ResourcePool "$vmClassName-$vmClassSem" 


Get-VM -Name "*-gold-*" -Location $rp | ForEach-Object {
	$mac = (Get-NetworkAdapter -VM $_).MacAddress
	$dnsName = $_.Name	
	$stream.WriteLine("<staticmap>")
	$stream.WriteLine("  <mac>$mac</mac>")
	$stream.WriteLine("  <ipaddr>$ipPrefix.$goldIP</ipaddr>")
	$stream.WriteLine("  <hostname>$dnsName</hostname>")
	$stream.WriteLine("  <descr/>")
	$stream.WriteLine("  <netbootfile/>")
	$stream.WriteLine("</staticmap>")
	$goldIP++
}

# 
# Loop through the templates
for ($i=0; $i -lt $vmTmplName.length; $i++) {
	# The Name of the Template used to make the VMs, minus the numbers
	$vmTemplateName = $vmClassName + "-" + $vmClassSem + "-" + $vmTmplName[$i] + "-"
	
	

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
		#$ip = $i + (($vmId - 1) * $ipPodPostfixSkip) + $ipPodPostfix
		$ip = [int]$ipPostfix[$i] + $vmId
		
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

$stream.write("	
</lan>
</dhcpd>
")


$stream.close()

################## BEGIN NAT RULES
 $outputFile = "Z:\IA-files\{0}_nat_{1}.xml" -f $vmClassName,$vmClassSem
$stream = [System.IO.StreamWriter] $outputFile
echo "NAT Output file: $outputFile"

$stream.WriteLine("<nat>")
$stream.WriteLine("	<ipsecpassthru>")
$stream.WriteLine("		<enable/>")
$stream.WriteLine("	</ipsecpassthru>")



#$stream = [System.IO.StreamWriter] # $null
$index = 1
$podNum = 1
While ($index -lt ($numPods + 1)) {
	$btIp = [int]$ipPostfix[0] + $index
	$CentOSIp = [int]$ipPostfix[1] + $index
   $XPIp = [int]$ipPostfix[2] + $index
   $2k3Ip = [int]$ipPostfix[3] + $index
	
	$btPort = $natBTStart + $index
	$CentOSPort = $natCentOSStart + $index
	$XPPort = $natWinXPStart + $index
	$2k3Port = $natWin2k3Start + $index


	$stream.WriteLine("	<rule>")
	$stream.WriteLine("		<source>")
	$stream.WriteLine("			<any/>")
	$stream.WriteLine("		</source>")
	$stream.WriteLine("		<destination>")
	$stream.WriteLine("			<network>wanip</network>")
	$stream.WriteLine("			<port>$btPort</port>")
	$stream.WriteLine("		</destination>")
	$stream.WriteLine("		<protocol>tcp</protocol>")
	$stream.WriteLine("		<target>$ipPrefix.$btIp</target>")
	$stream.WriteLine("		<local-port>5901</local-port>")
	$stream.WriteLine("		<interface>wan</interface>")
	$stream.WriteLine("		<descr/>")
	$stream.WriteLine("	</rule>")
	echo "To connect to backtrack $podNum, VNC to $vmClassName.ccs.neu.edu on port $btPort"
	
	$stream.WriteLine("	<rule>")
	$stream.WriteLine("		<source>")
	$stream.WriteLine("			<any/>")
	$stream.WriteLine("		</source>")
	$stream.WriteLine("		<destination>")
	$stream.WriteLine("			<network>wanip</network>")
	$stream.WriteLine("			<port>$CentOSPort</port>")
	$stream.WriteLine("		</destination>")
	$stream.WriteLine("		<protocol>tcp</protocol>")
	$stream.WriteLine("		<target>$ipPrefix.$CentOSIp</target>")
	$stream.WriteLine("		<local-port>22</local-port>")
	$stream.WriteLine("		<interface>wan</interface>")
	$stream.WriteLine("		<descr/>")
	$stream.WriteLine("	</rule>")
   echo "To connect to CentOS $podNum, remote desktop connect to $vmClassName.ccs.neu.edu on port $CentOSPort"

	$stream.WriteLine("	<rule>")
	$stream.WriteLine("		<source>")
	$stream.WriteLine("			<any/>")
	$stream.WriteLine("		</source>")
	$stream.WriteLine("		<destination>")
	$stream.WriteLine("			<network>wanip</network>")
	$stream.WriteLine("			<port>$XPPort</port>")
	$stream.WriteLine("		</destination>")
	$stream.WriteLine("		<protocol>tcp</protocol>")
	$stream.WriteLine("		<target>$ipPrefix.$XPIp</target>")
	$stream.WriteLine("		<local-port>3389</local-port>")
	$stream.WriteLine("		<interface>wan</interface>")
	$stream.WriteLine("		<descr/>")
	$stream.WriteLine("	</rule>")
   echo "To connect to WindowsXP $podNum, remote desktop into $vmClassName.ccs.neu.edu on port $XPPort"

	$stream.WriteLine("	<rule>")
	$stream.WriteLine("		<source>")
	$stream.WriteLine("			<any/>")
	$stream.WriteLine("		</source>")
	$stream.WriteLine("		<destination>")
	$stream.WriteLine("			<network>wanip</network>")
	$stream.WriteLine("			<port>$2k3Port</port>")
	$stream.WriteLine("		</destination>")
	$stream.WriteLine("		<protocol>tcp</protocol>")
	$stream.WriteLine("		<target>$ipPrefix.$2k3Ip</target>")
	$stream.WriteLine("		<local-port>3389</local-port>")
	$stream.WriteLine("		<interface>wan</interface>")
	$stream.WriteLine("		<descr/>")
	$stream.WriteLine("	</rule>")
   echo "To connect to Windows2k3 $podNum, remote desktop into $vmClassName.ccs.neu.edu on port $2k3Port"
   echo "#####"
   $podNum++

	$index++

}

$stream.WriteLine("</nat>")
$stream.close()
