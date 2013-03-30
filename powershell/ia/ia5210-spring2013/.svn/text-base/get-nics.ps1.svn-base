# Connect to the vsphere server
$server = connect-viserver "classroomvc.ccs.neu.edu"

$vmClassName = "ia5210"
$vmClassSem = "spr13"
$vmTmplName = "backtrack", "winxp", "win7-"
$numPods = 15 # Number of Pods to create rules for
$numVms = 3 # Number of VMs per Pod
$ipPrefix = "10.0.10"

$outputFile = "Z:\Desktop\{0}_dhcp_{1}.xml" -f $vmClassName,$vmClassSem
echo "DHCP Output file: $outputFile"

# The Postfix is the last octet of the IP address, given $ipPrefix is a /24
$ipBTPostfix = 50 
$ipWinXPPostfix = 150
$ipWin7Postfix = 200
$ipPostfix = $ipBTPostfix, $ipWinXPPostfix, $ipWin7Postfix
$ipPodPostfixSkip = 10 # Number of IPs to jump per pod

$natBTStart = 11000 # Base NAT port
$natWinStart = 12000
$natWin7Start = 13000
$natStart = $natBTStart, $natWinXPStart, $natWin7Start

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
		<staticmap>
			<mac>00:50:56:a7:04:b5</mac>
			<ipaddr>10.0.10.10</ipaddr>
			<hostname>ia5120-backtrack-gold-20130122</hostname>
			<descr/>
			<netbootfile/>
		</staticmap>
		<staticmap>
			<mac>00:50:56:a7:04:b8</mac>
			<ipaddr>10.0.10.11</ipaddr>
			<hostname>ia5210-win7-gold-20130122</hostname>
			<descr><![CDATA[gold image ia5210 a]]></descr>
			<netbootfile/>
		</staticmap>
		<staticmap>
			<mac>00:50:56:a7:46:72</mac>
			<ipaddr>10.0.10.12</ipaddr>
			<hostname>ia5210-winxp-gold-20130122</hostname>
			<descr><![CDATA[gold image ia5210 a]]></descr>
			<netbootfile/>
		</staticmap>
")
# 
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
 $outputFile = "Z:\Desktop\{0}_nat_{1}.xml" -f $vmClassName,$vmClassSem
$stream = [System.IO.StreamWriter] $outputFile
echo "NAT Output file: $outputFile"
#$stream = [System.IO.StreamWriter] # $null
$index = 1
$podNum = 1
While ($index -lt ($numPods + 1)) {
	$btIp = [int]$ipPostfix[0] + $index
	$xpIp = [int]$ipPostfix[1] + $index
   $w7IP = [int]$ipPostfix[2] + $index
	
	$btPort = $natBTStart + $index
	$xpPort = $natWinStart + $index
   $win7Port = $natWin7Start + $index


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
	$stream.WriteLine("		<local-port>22</local-port>")
	$stream.WriteLine("		<interface>wan</interface>")
	$stream.WriteLine("		<descr/>")
	$stream.WriteLine("	</rule>")
	echo "To connect to backtrack $podNum, ssh to ia5210.ccs.neu.edu on port $btPort"
	
	$stream.WriteLine("	<rule>")
	$stream.WriteLine("		<source>")
	$stream.WriteLine("			<any/>")
	$stream.WriteLine("		</source>")
	$stream.WriteLine("		<destination>")
	$stream.WriteLine("			<network>wanip</network>")
	$stream.WriteLine("			<port>$xpPort</port>")
	$stream.WriteLine("		</destination>")
	$stream.WriteLine("		<protocol>tcp</protocol>")
	$stream.WriteLine("		<target>$ipPrefix.$xpIp</target>")
	$stream.WriteLine("		<local-port>3389</local-port>")
	$stream.WriteLine("		<interface>wan</interface>")
	$stream.WriteLine("		<descr/>")
	$stream.WriteLine("	</rule>")
   echo "To connect to WindowsXP $podNum, remote desktop connect to ia5210.ccs.neu.edu on port $xpPort"

	$stream.WriteLine("	<rule>")
	$stream.WriteLine("		<source>")
	$stream.WriteLine("			<any/>")
	$stream.WriteLine("		</source>")
	$stream.WriteLine("		<destination>")
	$stream.WriteLine("			<network>wanip</network>")
	$stream.WriteLine("			<port>$win7Port</port>")
	$stream.WriteLine("		</destination>")
	$stream.WriteLine("		<protocol>tcp</protocol>")
	$stream.WriteLine("		<target>$ipPrefix.$w7Ip</target>")
	$stream.WriteLine("		<local-port>3389</local-port>")
	$stream.WriteLine("		<interface>wan</interface>")
	$stream.WriteLine("		<descr/>")
	$stream.WriteLine("	</rule>")
   echo "To connect to Windows 7 $podNum, remote desktop into ia5210.ccs.neu.edu on port $win7Port"
   echo "#####"
   $podNum++

	$index++

}
$stream.close()
