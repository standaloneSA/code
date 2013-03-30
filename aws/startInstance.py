#!/usr/bin/env python

import boto
from pprint import pprint 

ec2 = boto.connect_ec2()

# us-east-1 precise (12.04 LTS) i386
AMIID = "ami-9878c0f1"
# us-east-1 precise (12.04 LTS) amd64
#AMIID = "ami-9c78c0f5"
# us-west-1 precise (12.04 LTS) i386
#AMIID = "ami-b94f69fc"
# us-west-1 precise (12.04 LTS) amd64
#AMIID = "ami-bb4f69fe"

secGroups = ec2.get_all_security_groups()

print secGroups


#ec2.run_instances(
#		AMIID, 
#		key_name="automate_key",
#		instance_type="t1.micro", 
#		security_groups="default"
#		)



