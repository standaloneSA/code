#!/usr/bin/python 

#import argparse
import socket
import time
import sys
import getopt


CARBON_SERVER = 'graphite.ccs.neu.edu'
CARBON_PORT = 2003


#parser = argparse.ArgumentParser()
#parser.add_argument('metric_path')
#parser.add_argument('value')
#args = parser.parse_args()

try: 
	metric_path = sys.argv[1]
	value = sys.argv[2]
except:
	print 'Error: Usage: toGraphite.py metric_path value'
	sys.exit(2)


if __name__ == '__main__':
	timestamp = int(time.time())
	message = '%s %s %d\n' % (metric_path, value, timestamp)
	
	print 'sending message:\n%s' % message
	sock = socket.socket()
	sock.connect((CARBON_SERVER, CARBON_PORT))
	sock.sendall(message)
	sock.close()
