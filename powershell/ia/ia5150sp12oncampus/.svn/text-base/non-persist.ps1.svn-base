$server = connect-viserver "vsphere.ccs.neu.edu"
Get-VM "ia5150-sp2012-oncampus-*" | Get-HardDisk | Set-HardDisk -Persistence "IndependentNonPersistent" -Confirm:$false