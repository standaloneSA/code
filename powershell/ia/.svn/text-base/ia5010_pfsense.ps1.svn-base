$stream = [System.IO.StreamWriter] "Z:\.WIN_PROFILE\Desktop\ia5010_nat2.txt"

$btstart = 101
$winstart = 121
$num = 17

$index = $btstart
While ($index -lt ($btstart + $num)) {
	$stream.WriteLine("	<rule>")
	$stream.WriteLine("		<source>")
	$stream.WriteLine("			<any/>")
	$stream.WriteLine("		</source>")
	$stream.WriteLine("		<destination>")
	$stream.WriteLine("			<network>wanip</network>")
	$stream.WriteLine("			<port>10$index</port>")
	$stream.WriteLine("		</destination>")
	$stream.WriteLine("		<protocol>tcp</protocol>")
	$stream.WriteLine("		<target>10.0.10.$index</target>")
	$stream.WriteLine("		<local-port>22</local-port>")
	$stream.WriteLine("		<interface>wan</interface>")
	$stream.WriteLine("		<descr/>")
	$stream.WriteLine("	</rule>")
	$index++
}
$index = $winstart
While ($index -lt ($winstart + $num)) {
	$stream.WriteLine("	<rule>")
	$stream.WriteLine("		<source>")
	$stream.WriteLine("			<any/>")
	$stream.WriteLine("		</source>")
	$stream.WriteLine("		<destination>")
	$stream.WriteLine("			<network>wanip</network>")
	$stream.WriteLine("			<port>10$index</port>")
	$stream.WriteLine("		</destination>")
	$stream.WriteLine("		<protocol>tcp</protocol>")
	$stream.WriteLine("		<target>10.0.10.$index</target>")
	$stream.WriteLine("		<local-port>3389</local-port>")
	$stream.WriteLine("		<interface>wan</interface>")
	$stream.WriteLine("		<descr/>")
	$stream.WriteLine("	</rule>")
	$index++
}
$stream.close()
