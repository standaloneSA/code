$server = connect-viserver "vsphere.ccs.neu.edu"
Get-VM -Name "ia5010-fall2011-*" | Start-VM -RunAsync