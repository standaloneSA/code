﻿# Connect to the vsphere server
$server = connect-viserver "classroomvc.ccs.neu.edu"

$outputFile = "Z:\Desktop\ia5010_dhcp_spring2013.txt"
$ipPrefix = "10.0.10"
$numPods = 23 # Number of Pods to create rules for
$numVms = 2 # Number of VMs per Pod
$ipBTPostfix = 50 # Starting IP to go up from
$ipWinPostfix = 150
$ipPodPostfixSkip = 10 # Number of IPs to jump per pod
$natBTStart = 11000 # Base NAT port
$natWinStart = 12000

$ipPostfix = 50, 150

$natStart = 11000, 12000

$vmClassName = "ia5010"
$vmClassSem = "sp13"
$vmTmplName = "bt", "winxp"

# Open a stream for writing
$stream = [System.IO.StreamWriter] $outputFile
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
			<mac>00:50:56:ad:00:32</mac>
			<ipaddr>10.0.10.8</ipaddr>
			<hostname>ia5010-win2k3</hostname>
			<descr/>
			<netbootfile/>
		</staticmap>
		<staticmap>
			<mac>00:50:56:ad:00:58</mac>
			<ipaddr>10.0.10.9</ipaddr>
			<hostname>ia5010-webserver</hostname>
			<descr/>
			<netbootfile/>
		</staticmap>
		<staticmap>
			<mac>00:50:56:ad:00:08</mac>
			<ipaddr>10.0.10.10</ipaddr>
			<hostname>ia5120-win2k3-gold</hostname>
			<descr/>
			<netbootfile/>
		</staticmap>
		<staticmap>
			<mac>00:50:56:ad:00:02</mac>
			<ipaddr>10.0.10.11</ipaddr>
			<hostname>ia5010-backtrack-gold</hostname>
			<descr/>
			<netbootfile/>
		</staticmap>
		<staticmap>
			<mac>00:50:56:ad:00:0c</mac>
			<ipaddr>10.0.10.12</ipaddr>
			<hostname>ia5010-xp-gold</hostname>
			<descr><![CDATA[gold image ia5010 a]]></descr>
			<netbootfile/>
		</staticmap>
		<staticmap>
			<mac>00:50:56:ad:00:10</mac>
			<ipaddr>10.0.10.13</ipaddr>
			<hostname>ia5010-backtrack-test</hostname>
			<descr/>
			<netbootfile/>
		</staticmap>
		<staticmap>
			<mac>00:50:56:ad:00:11</mac>
			<ipaddr>10.0.10.14</ipaddr>
			<hostname>winxp-test</hostname>
			<descr/>
			<netbootfile/>
		</staticmap>
		<staticmap>
			<mac>00:50:56:ad:00:0e</mac>
			<ipaddr>10.0.10.15</ipaddr>
			<hostname>ia5211-win7</hostname>
			<descr/>
			<netbootfile/>
		</staticmap>
		<staticmap>
			<mac>00:50:56:a7:4e:52</mac>
			<ipaddr>10.0.10.16</ipaddr>
			<hostname>ia5211-backtrack-test</hostname>
			<descr/>
			<netbootfile/>
		</staticmap>
	")
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
$stream = [System.IO.StreamWriter] "Z:\Desktop\ia5010_nat_spring2013.txt"
$index = 1
While ($index -lt ($numPods + 1)) {
	$xpIp = [int]$ipPostfix[1] + $index
	$btIp = [int]$ipPostfix[0] + $index
	
	$btPort = $natBTStart + $index
	$xpPort = $natWinStart + $index


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
	
	$index++
}
$stream.close()