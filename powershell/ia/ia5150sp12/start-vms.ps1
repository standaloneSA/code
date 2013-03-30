$server = connect-viserver "vsphere.ccs.neu.edu"
Get-VM -Name "ia5150-spring2012-*" | Start-VM -RunAsync