#!/usr/bin/perl 

use strict; 

use Net::IMAP::Simple::SSL; 

my $server = "myimapserver";
my $user = 'myemail@mydomain';
my $pass = "mypassword";

my $imap = Net::IMAP::Simple::SSL->new($server); 

$imap->login($user => $pass); 

my $total_messages = $imap->select("Inbox"); 

printf "Total Messages: $total_messages\n"; 

