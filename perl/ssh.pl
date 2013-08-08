#!/arch/unix/bin/perl -w 

use strict; 

use Net::SSH::Perl; 
use Term::ReadKey; 

my $host; 
my $user; 
my $pass; 
my $enableSecret; 

$host = "rotary.ccs.neu.edu"; 

$user = getlogin; 

print "Please enter your password: "; 
ReadMode('noecho'); 
$pass = ReadLine(0); 
print "\n"; 
ReadMode('normal'); 


ReadMode('noecho'); 
print "Please enter the enable secret: "; 
$enableSecret = ReadLine(0); 
print "\n"; 
ReadMode('normal'); 

chomp($pass); 
chomp($enableSecret); 

my $ssh = Net::SSH::Perl->new($host, protocol => 1, debug => 1); 
my $stdout;
my $stderr;
my $exitcode;
$ssh->login($user, $pass); 
($stdout, $stderr, $exitcode) = $ssh->cmd("sh clock"); 
print "$stdout\n"; 
($stdout, $stderr, $exitcode) = $ssh->cmd("en"); 
print "$stdout\n"; 
print "$stderr\n"; 
($stdout, $stderr, $exitcode) = $ssh->cmd($enableSecret); 
print "$stdout\n"; 


