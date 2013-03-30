#!/usr/bin/python

import getopt,sys,os

hostbase = "/net/ccis/bin/hostbase"

def main():
	ip = ''

	try:
		opts, args = getopt.getopt(sys.argv[1:],'',"ip=")
	except getopt.GetoptError as err:
		print(err)
		usage()
		sys.exit(2)
	for o, a in opts:
		if o == "--ip":
			ipblock = a
		else:
			assert False, "unhandled argument"
	IPList = hostbase,"-print ip -ip ",ipblock

	print IPList



if __name__ == "__main__":
	main()

#print socket.gethostbyaddr('129.10.118.215')


