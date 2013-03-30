#!/bin/bash
# ahc.sh (automate host creation)
# 
# This script's purpose is to automate as much of the 
# host creation process as possible. Right now, there 
# are 7 specific steps which require human interaction. 
# This is silly. 
# The goal is to eliminate human interaction except for
# the invocation of the script (either CLI or eventually 
# web form). The human should stick to making decisions
# and the computer should be responsible for doing boring
# things. 
#
# -MS 20130103

# The only things that the human should ideally need to provide
# are the machine's host name and network. Everything else
# should be automated, from creating the VM to generating the
# MAC address to modifying hostbase. These are things that are
# currently done by the human because the automation was never 
# put into place. 
# 
# I'm starting with the low-hanging fruit, and adding harder
# things as I go. If you see something here that's not automated
# and you feel like it could be, by all means write it. 

# for now, lets just function as a way to conveniently provide info.

if [ "$2" == "" ] ; then 
	echo "Usage: $0 <mac address> <hostname>" 
	exit
fi

# Find free IP address

if [ "`uname`" == "SunOS" ] ; then 
	SORT="/opt/sfw/bin/gsort"
else
	SORT="/usr/bin/sort"
fi

# List IPs we've found
hostbase -ip 129.10.116 129.10.117 -print ip | $SORT -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4
