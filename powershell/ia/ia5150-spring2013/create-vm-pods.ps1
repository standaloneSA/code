# create-vm-pods.ps1
#
# The difference between this and the normal script is that this is a 
# response to ticket 105407's request to have a pod of VMs assume 
# consecutive IPs, so that a student can type a range of addresses, 
# rather than several individual hosts. 

# This is the number of students. Each student gets one pod which
# consists of multiple VMs.
$vmPods = 45 

# We have this so that we can append new pods 
$podIndex = 1 

$server = connect-viserver "classroomvc.ccs.neu.edu"

$classCode = "ia5150"
$semester = "spring-2013"

# These are what the cloned machines will be named, with
# an index number appended at the end
$newTemplateName = @()
$newTemplateName += "ia5150-spring-2013-backtrack-"
$newTemplateName += "ia5150-spring-2013-win2k3-"
$newTemplateName += "ia5150-spring-2013-winxpsp2-"
$newTemplateName += "ia5150-spring-2013-centos5.5-"

# The linkclone masters are the sources for the new VMs. 
# The order in this array needs to match the order in the
# $newTamplateName array
$LCMASTERS = $()
$LCMASTERS += (Get-Template "ia5150-backtrack5-LCMASTER-20130214")
$LCMASTERS += (Get-Template "ia5150-win2k3-LCMASTER-20130214")
$LCMASTERS += (Get-Template "ia5150-winxpsp2-LCMASTER-20130214")
$LCMASTERS += (Get-Template "ia5150-centos5.5-LCMASTER-20130214")

$vmCluster = Get-Cluster "Teaching"

$vmDatastore = (Get-Datastore -name "ankh-nfs" | Get-View)

$vmResourcePool = ($vmCluster | Get-ResourcePool "$classCode-$semester" | Get-View)

$index = $podIndex
while ($index -lt ($podIndex + $vmPods)) { 
	$vmHost = ($vmCluster | Get-VMHost | Sort $_.MemoryUsageMB -Descending | Select -First 1 | Get-View)
	Write-Host "Creating 

