$viServer = "classroomvc.ccs.neu.edu"
$classCode = "ia5150"
$semester = "spring-2013"
$targetDS = "ankh-nfs"

#### Get things connected and ready to go ####

# Set the InvalidCertificateAction to warn so that future PowerCLIs don't
# automatically fail to connect us. 
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Scope Session -confirm:$false | out-null

# test to see if we're connected before we, you know, connect 
if (@($DefaultVIServers).length -eq 0) {
	write-host "Connecting to $viServer"
	Connect-VIServer $viServer | out-null
} else { 
	if (@($DefaultVIServers).length -gt 1) { 
		# There's the possibility that we make some assumptions that the VI host isn't an array...
		# There are various modes available through Set-PowerCLIConfiguration that would allow
		# us to mandate only one connection, but there are set to be changes in the next ver of
		# powerCLI (currently at 5.1 as I write this)
		# -MS 20130204
		write-host "Sorry, this script only supports being connected to a single host."
		write-host "It appears that you are connected to" @($DefaultVIServers).length
		write-host "Exiting now..."
		exit
	}
	write-host "Already connected to" $DefaultVIServers
	$continue = read-host  "Continue while using this server? (y/n): "
	if ($continue -ne "y") { 
		exit
	} else {
		$NODISASSEMBLE = 1
		$viServer = $DefaultVIServers
	}
}
#### We should now be connected, stable, and ready to rock and roll #### 

# Step 0: Setup some variables we'll need 

$MSIAfolder = get-folder -name MSIA
$MSIArespool = get-resourcepool -name MSIA

# Step 1: Get the Class Code

#do { 
#	$readCode = read-host "Please enter the class code for the new class (example: IA5210): "
#	if ($readCode.Contains(" ")) { 
#		write-host "Sorry, class codes should not contain spaces"
#		exit
#	}
#	$classCode = $classCode.toUpper()
#} while ($classCode -ne $null))

$classRP = Get-ResourcePool -name "$classCode-$semester"
$arrGoldVMs = Get-VM -Location $classRP -name "*-gold-*" 

$arrGoldVMs | ForEach-Object { 
	Write-Host "Cloning $_.name" 
	
