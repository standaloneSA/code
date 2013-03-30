$PREFIX = "CCIS.systems.vsphere"
$GRAPHITESERVER = "graphite.ccs.neu.edu" 
$GRAPHITEPORT = 2003

function AvgStat ($list) { 
	return [Math]::Round(($list | Measure-Object Value -Average).Average,2)
}

	$vmHosts = Get-Cluster Teaching | Get-VMHost

	$StatsToGet = @()
	$StatsToGet += "cpu.usage.average"
	$StatsToGet += "mem.usage.average"
	$StatsToGet += "disk.maxtotallatency.latest"
	$StatsToGet += "net.usage.average"
	$StatsToGet += "mem.shared.average"
	$StatsToGet += "mem.swapused.average"
	$StatstoGet += "mem.llswapout.average"
#	$StatsToGet += "storagepath.throughput.usage.average"


	foreach ( $vmHost in $vmHosts ) { 
		foreach ( $stat in $StatsToGet ) { 
			$avgStatRes = AvgStat(Get-Stat -entity $vmHost -stat $stat -Start (Get-Date).AddMinutes(-5) -IntervalMins 1 -MaxSamples (12))

			$thisHost = ($vmHost.Name -split "\.")[0]
			$now = Get-Date -UFormat "%s"
			$statName = $stat -replace "\.","_"
			$metricPath = "$PREFIX.$thisHost.$statName"
			Write-Host ("$metricPath	$avgStatRes		$now")

			$socket = New-Object System.Net.Sockets.TCPClient
			$socket.connect($GRAPHITESERVER, $GRAPHITEPORT)
			$stream = $socket.GetStream()
			$writer = new-object System.IO.StreamWriter($stream)

			$writer.WriteLine("$metricPath	$avgStatRes		$now")
			$writer.Flush()
			$writer.Close()
			$stream.Close()
			$socket.Close()
		}
	}


