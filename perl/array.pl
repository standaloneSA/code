#!/usr/bin/perl -w 

use strict; 

my @array = ("one", "two", "three", "four"); 

my $array_ref = \@array; 

print $array_ref . "\n"; 

foreach (@{ $array_ref }) { 
	print $_ . "\n"; 
}

