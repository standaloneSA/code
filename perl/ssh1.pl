#!/arch/unix/bin/perl -w 

use strict; 

#use Net::SSH::Perl; 
use Net::Appliance::Session; 
use Term::ReadKey; 

my $host; 
my $user; 
my $pass; 

$host = "rotary.ccs.neu.edu"; 

$user = getlogin; 

print "Please enter your password: "; 
ReadMode('noecho'); 
$pass = ReadLine(0); 
print "\n"; 
ReadMode('normal'); 

chomp($pass); 

my $session = Net::Appliance::Session->new(
	Host 			=> $host, 
	Transport 	=> 'SSH',
); 

# my $ssh = Net::SSH::Perl->new($host, protocol => 1); 
my $stdout;
my $stderr;
my $exitcode;
#$ssh->login($user, $pass); 
$session->connect(
	Name 			=> $user, 
	Password 	=> $pass
); 

# ($stdout, $stderr, $exitcode) = $ssh->cmd("sh ip int brief Fa0/48");

print $session->cmd('sh ip int brief Fa0/48'); 
print "\n"; 

$session->close; 


