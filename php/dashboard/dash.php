<?php
// dash.php
//
// Mark I 
// 
// Creates a dashboard single pane of glass for the infrastructure

$user = "msimmons"; 
$pass = ""; 

$tmpDir = "./tmp"; 

$arrGraphs = array(
	new localGraph(


//////////////////////////////////


class localGraph { 
	public $remURL = ""; 
	public $LinkURL = ""; 
	public $Title = ""; 
	public $localURL = ""; 

	__construct($Title, $URL, $LinkURL) { 

		$this->Title = $Title; 
		$this->remURL = $URL; 
		$this->LinkURL = $LinkURL; 

		$this->getRemoteGraph(); 
	} // end constructor


	function displayGraph() { 
		print '<div class="displayGraph">'; 
		print '<a href="' . $this->LinkURL . '">\n'; 
		print '<img src="' . $this->URL . '" class="displayGraph">\n'; 
		print '<div class="displayGraphLabel">' . $this->Title . '</div>\n'; 
		print '</div>\n'; 
	} // end displayGraph()

	function getRemoteGraph()  { 
		// basically, curl the remote image, 
		// store it in the local tmpdir, and 
		// then set the variable in this object


		global $user, $pass; 
		global $tmpDir; 

		if ( ! $this->remURL ) { 
			return -1; 
		}

		$imageHandle = curl_init($this->remURL); 
		
		$localFN = "$tmpDir" . "/" . 	str_replace('/','_',$this->Title) . " - " . date("Ymd:Hm"); 
		if ( ! file_exists($localFN) ) { 
			$localHandle = fopen($localFN, "w"); 

			curl_setopt($imageHandle, CURLOPT_FILE, $localHandle); 
			curl_setopt($imageHandle, CURLOPT_HEADER, 0); 
			curl_setopt($imageHandle, CURLOPT_SSL_VERIFYPEER, 0); 
			curl_setopt($imageHandle, CURLOPT_USERPWD, "$user:$pass"); 

			curl_exec($imageHandle); 
			curl_close($imageHandle); 
			fclose($localHandle); 
		} else { 
			curl_close($imageHandle); 
		}

		$this->localURL = $localFN; 

	} // end getRemoteGraph()

} // end class remoteGraph



