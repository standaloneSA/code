#!/usr/bin/perl 
#
use warnings; 
use strict; 
use SNMP; 
use Socket; 

my $commString = "publickeygoeshere"
my $host			= "bullpup.ccs.neu.edu"
my $mib			= "sysDescr"
my $sver			= "2"

my $sess; 
my $var; 
my $vb;

&SNMP::initMib(); 

my %snmpparms; 
$snmpparms{Community} = $comm;
$snmpparms{DestHost} = inet_ntoa(inet_aton($dest)); 
$snmpparms{Version} = $sver; 
$snmpparms{UseSprintValue} = '1'; 

$sess = new SNMP::Session(%snmpparms); 

$vb = new SNMP::Varbind([$mib, '0']); 
$var = $sess->get($vb); 

if ($sess->{ErrorNum}) { 
	die "Got $sess->{ErrorStr} querying $dest for $mib.\n";
}
print $vb->tag, ".", $fb->iid, " : $var\n"; 

$mib = 'ipNetToMediaPhysAddress'; 
$vb = new SNMP::Varbind([$mib]); 

for ( 
	$var = $sess->getnext($vb); 
	($vb->tag eq $mib) and not ($sess->{ErrorNum}); 
	$var = $sess->getnext($vb)
) { 
	print $vb->tag, ".", $vb->iid, " : ", $var, "\n"; 
}

if ($sess->{ErrorNum}) { 
	die "Got $sess->{ErrorStr} querying $dest for $mib.\n"; 
}

