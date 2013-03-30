#!/usr/bin/env python

import boto
from pprint import pprint

# connect to ec2
ec2 = boto.connect_ec2()
print "Connected to ec2\n"

# find any reservations we've got 
rsv = ec2.get_all_instances()
print "got all instances\n"

print "Images: \n"
images = ec2.get_all_images()

# stupid languages without braces
# instances = [i for r in rsv for i in r.instances]
instances = []
for r in rsv:
	for i in r.instances:
		instances.append(i)


print "instances initialized\n"
for i in instances:
	pprint(i.__dict__)
	break
	

