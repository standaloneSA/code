# 1_New_IA_Class.ps1

<#
 This script is used to create a new "class" in the classroomVC vSphere
	environment. The "class" really just consists of a folder tree under 
	MSIA in the CCIS datacenter, plus a Resource Group under MSIA in the
	Teaching cluster. 

	-MS 20130204
	standalone.sysadmin@gmail.com
#>


$viServer = "classroomvc.ccs.neu.edu"

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

do { 
	$readCode = read-host "Please enter the class code for the new class (example: IA5210): "
	if ($readCode.Contains(" ")) { 
		write-host "Sorry, class codes should not contain spaces"
		exit
	}
	$classCode = $classCode.toUpper()
} while ($classCode -ne $null))







# Step 2: Get the Semester

# Step 3: Create the folders

# Step 4: Create the Resource Pool





#### Disconnect #### 

if ( $NODISASSEMBLE -ne 1 ) { 
	write-host "Disconnecting from server $DefaultViServers"
	Disconnect-viserver $viServer -confirm:$false 
}

