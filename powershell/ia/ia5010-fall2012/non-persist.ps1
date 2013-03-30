$server = connect-viserver "classroomvc.ccs.neu.edu"
Get-VM "ia5010-f12-*" | Get-HardDisk | Set-HardDisk -Persistence "IndependentNonPersistent" -Confirm:$false