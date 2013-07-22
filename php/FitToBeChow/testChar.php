<?php

include "./characters.php"; 

$charVals = array( 
	"name" => "Matt", 
	"level" => "1", 
	"hitpoints" => array(
		"label" => "Stamina", 
		"value" => "20"
	)
); 

$mychar = new player($charVals); 

$mycharText = serialize($mychar); 

unset($mychar); 

$myNewChar = unserialize($mycharText); 
print "\n-\n$mycharText\n-\n"; 

//print_r($myNewChar); 


print $myNewChar->getDamage() . "\n"; 


