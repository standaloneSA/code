<?php
// testZombie.php 
//

require 'characters.php'; 

$myZombie = new zombie(intval($argv[1])); 

print_r($myZombie); 
