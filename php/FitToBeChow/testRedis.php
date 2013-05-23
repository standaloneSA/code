<?php
// testRedis.php
//
// We're going to instantiate a player, serialize them, then pull them back

require 'characters.php'; 

$redis = new Redis(); 
$redis->connect('127.0.0.1'); 

if ( ! isset($argv[1]) ) { 
	print "Usage: " . $argv[0] . " <username>\n"; 
	exit;
}

$username = $argv[1]; 

if ( ! $player1txt = $redis->get($username) ) { 
	$player1 = new player("new"); 
	$player1->setName("Matt"); 
	$player1->setUserName($username); 
} else { 
	$player1 = unserialize($player1txt); 
}

$player1->spendMoney(25); 

$serialData = serialize($player1); 
//print "Storing: $serialData\n"; 
$redis->set($username, $serialData); 

if ( $argv[2] == "del" ) { 
	$redis->delete($username); 
}

$redis->close(); 




