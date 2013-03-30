#!/usr/bin/python

import sys
import time
import os
import platform
import subprocess
import socket
import telnetlib


HostName = socket.gethostname()
CARBON_SERVER = 'watchtower.ccs.neu.edu'
CARBON_PORT = 2003
CARBON_NAME = "CCIS.systems." + HostName + ".loggedInUsers"

#curUsers = os.system("/usr/bin/who | /usr/bin/wc -l")
process = subprocess.Popen(["/usr/bin/who"], stdout=subprocess.PIPE)
os.waitpid(process.pid, 0)
output = process.stdout.read()

numNames = output.count("\n"); 
now = int( time.time() )
outLine = []
outLine.append("%s %s %i" % (CARBON_NAME, numNames, now))

#sock = socket.socket()
#try:
#	sock.connect( (CARBON_SERVER,CARBON_PORT) )
#except: 
#	print "Couldn't connect to %(server)s on port %(port), is carbon-agent running?" % { 'server':CARBON_SERVER, 'port':CARBON_PORT }
#	sys.exit(1) 

print "Sending " + outLine[0]

tn = telnetlib.Telnet(CARBON_SERVER, CARBON_PORT)

tn.write(outLine[0])


#//sock.sendall(outLine[0])






#type(curUsers)
#os.system("/usr/bin/who | /usr/bin/wc -l")




