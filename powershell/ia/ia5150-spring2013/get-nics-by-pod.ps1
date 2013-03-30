# Connect to the vsphere server

$server			= "classroomvc.ccs.neu.edu"
$classCode		= "ia5150"
$semester		= "spring-2013"
$dhcpFile 		= "Z:\IA-files\{0}_dhcp_{1}.xml" -f $classCode,$semester
$natFile			= "Z:\IA-files\{0}_nat_{1}.xml" -f $classCode,$semester
$numPods 		= 45 # Number of Pods to create rules for
$numVms 			= 4 # Number of VMs per Pod
$ipPrefix 		= "10.0.10"
$goldIPStart	= 5
# The fallback range is to have an open DHCP pool "just in case"
$fallbackStart	= "240"
$fallbackStop	= "245"
$ipStart 		= 50 
$today			= get-date -format yyyyMMdd

try { Connect-VIServer $server -ea stop } 
catch [Exception] { 
	Write-Host "Unable to connect to $server :"
	Write-Host $_.Exception.Message
	exit
}


try { $rp = Get-ResourcePool "$classCode-$semester" -ea stop} 
catch { 
	Write-Host "Sorry, there was an error locating the resource pool $classCode-semester"
	Disconnect-VIServer $server -confirm:$false
	exit
}


$vmImages = @{ 
	"backtrack"	= @{
		"targetPort" 	= "5901"
		"basePort" 		= "11000"
	}
	"centos5.5"	= @{
		"targetPort"	= "22"
		"basePort"		= "12000"
	}
	"win2k3"		= @{ 
		"targetPort"	= "3389"
		"basePort"		= "14000"
	}
	"winxpsp2"	= @{
	}
} 

try { 
	$dhcpWriter = [System.IO.StreamWriter] $dhcpFile
	$natWriter	= [System.IO.StreamWriter] $natFile
} 
catch { 
	Write-Host "Sorry, there was an error writing to one of the output files:"
	Write-Host "	$dhcpFile"
	Write-Host "	$natFile"
	$dhcpWriter.close()
	$natWriter.close()
	Disconnect-VIServer $server -confirm:$false
	exit
}

# Since we're writing the entire DHCP config, this sets up the static portion of the file
$dhcpWriter.Write("
<dhcpd>
   <lan>
      <enable/>
      <range>
         <from>$ipPrefix.$fallbackStart</from>
         <to>$ipPrefix.$fallbackStop</to>
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
"); 

# Now we do the same for the NAT config
$natWriter.Write("
<nat>
	<ipsecpassthru>
		<enable/>
	</ipsecpassthru>
")

# Set up the DHCP environment for the gold images. We don't really care 
# about what IP they're on, just that they can get internet access for
# updates and such. 
Get-VM -Name "*-gold-*" -Location $rp | ForEach-Object { 
	$mac = (Get-NetworkAdapter -VM $_).MacAddress
	$hostname = $_.Name
   $dhcpWriter.WriteLine("<staticmap>")
   $dhcpWriter.WriteLine("  <mac>$mac</mac>")
   $dhcpWriter.WriteLine("  <ipaddr>$ipPrefix.$goldIPStart</ipaddr>")
   $dhcpWriter.WriteLine("  <hostname>$dnsName</hostname>")
   $dhcpWriter.WriteLine("  <descr/>")
   $dhcpWriter.WriteLine("  <netbootfile/>")
   $dhcpWriter.WriteLine("</staticmap>")
   $goldIPStart++
}

# ############################################
# Loop through pods

$lastOctet = $ipStart
for ($i = 1; $i -le $numPods; $i++) { 
	Write-Host "### Pod $i"
	$vmImages.keys | ForEach-Object { 
		$vmName = $_

		$targetPort 	= $vmImages[$_]["targetPort"]
		$accessPort 	= [int]$vmImages[$_]["basePort"] + $i
		$ipAddress 		= "$ipPrefix.$lastOctet"
		$hostname 		= "$classCode-$semester-$vmName-$i"

		try { 
			$thisVM = Get-VM -Name "$classCode-$semester-$vmName-$i" -ea stop
			$macAddress = (Get-NetworkAdapter -VM $thisVM -ea stop).MacAddress
		} 
		catch [Exception] {
			Write-Host "There was an error accessing VM $classCode-$semester-$vmName-$i :"
			Write-Host $_.Exception.Message
			$dhcpWriter.close()
			$natWriter.close()
			Disconnect-VIServer $server -confirm:$false
			exit
		}

		# DHCP config
		$dhcpWriter.WriteLine("<staticmap>")
		$dhcpWriter.WriteLine("	<mac>$macAddress</mac>")
		$dhcpWriter.WriteLine("	<ipaddr>$ipAddress</ipaddr>")
		$dhcpWriter.Writeline(" <hostname>$classCode-$semester-$vmName-$i</hostname>")
		$dhcpWriter.Writeline("	<descr>Automatically generated $today</descr>")
		$dhcpWriter.Writeline("	<netbootfile/>")
		$dhcpWriter.Writeline("</staticmap>")

		# NAT config	
		if ($vmImages[$_]["basePort"] -ne $null) { 
			$natWriter.WriteLine("<rule>")
			$natWriter.WriteLine("	<source>")
			$natWriter.WriteLine("		<any/>")
			$natWriter.WriteLine("	</source>")
			$natWriter.WriteLine("	<destination>")
			$natWriter.WriteLine("		<network>wanip</network>")
			$natWriter.WriteLine("		<port>$accessPort</port>")
			$natWriter.WriteLine("	</destination>")
			$natWriter.WriteLine("	<protocol>tcp</protocol>")
			$natWriter.WriteLine("	<target>$ipAddress</target>")
			$natWriter.WriteLine("	<local-port>$targetPort</local-port>")
			$natWriter.WriteLine("	<interface>wan</interface>")
			$natWriter.WriteLine("	<descr>Automatically generated $today</descr>")
			$natWriter.WriteLine("</rule>")
			Write-Host "Access $vmName-$i 	(internal IP $ipAddress) on $classCode.ccs.neu.edu port $accessPort"
		} else {
			Write-Host "Access $vmName-$i via internal IP $ipAddress"
		}

		$lastOctet++
	}

}

$dhcpWriter.WriteLine("</lan>")
$dhcpWriter.WriteLine("</dhcpd>")
$natWriter.WriteLine("</nat>")

# Close the streams
$dhcpWriter.close()
$natWriter.close()

