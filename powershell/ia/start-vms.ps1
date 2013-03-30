$server = connect-viserver "vsphere.ccs.neu.edu"
Get-VM -Name "ia5130-fall2011-vm*" | Start-VM -RunAsync