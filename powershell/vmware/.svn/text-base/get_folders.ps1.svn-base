filter Get-FolderPath {
    $_ | Get-View | % {
        $row = "" | select Name, Path
        $row.Name = $_.Name
 
        $current = Get-View $_.Parent
#        $path = $_.Name # Uncomment out this line if you do want the VM Name to appear at the end of the path
        $path = ""
        do {
            $parent = $current
            if($parent.Name -ne "vm"){$path = $parent.Name + "\" + $path}
            $current = Get-View $current.Parent
        } while ($current.Parent -ne $null)
        $row.Path = $path
        $row
    }
}


Connect-VIServer -Server vsphere.ccs.neu.edu -Protocol https
# Export VM lists in a nice Excel List

$vmhostvms = get-vmhost -name "baldwin*" | get-vm

$rows = @()
Foreach ($VM in $vmhostvms) {
 $View = $VM | get-view
 $Config = $View.config
 if ($Config.Template) { continue } # Skip templates

 $row = New-Object -TypeName PSObject
 $res = Get-ResourcePool -VM $View.Name
 $path = ($VM | Get-Folderpath).Path
 $row | Add-Member -MemberType NoteProperty -Name VM -Value  $Config.Name
 
 #$row | Add-Member -MemberType NoteProperty -Name Hostname -Value $View.Guest.HostName
 #$row | Add-Member -MemberType NoteProperty -Name IP -Value ($View.Guest.IPAddress -replace "129.10","")
 $row | Add-Member -MemberType NoteProperty -Name ResourcePool -Value $res.Name
 $row | Add-Member -MemberType NoteProperty -Name Folder -Value $path
 #$row | Add-Member -MemberType NoteProperty -Name PoweredOn -Value ($VM.PowerState -replace "Powered","")
 #$row | Add-Member -MemberType NoteProperty -Name Cpu -Value  $Config.Hardware.NumCPU
 #$row | Add-Member -MemberType NoteProperty -Name Ram -Value  $Config.Hardware.MemoryMB
 #$row | Add-Member -MemberType NoteProperty -Name FullOS -Value (($Config.GuestFullName -replace "Windows Server", "") -replace "Linux", "")
 #$row | Add-Member -MemberType NoteProperty -Name Tools -Value ($View.Guest.ToolsStatus -replace "tools", "")

 Write-Host "VM: $VM" -ForegroundColor blue
 $rows += $row
}

$rows |sort VM
#| Export-Csv "vms.csv" -NoTypeInformation