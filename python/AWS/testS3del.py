#!/usr/bin/env python

import boto

s3 = boto.connect_s3()

bucket = s3.get_bucket('media.thecircus.org')

mykey = boto.s3.key.Key(bucket)

for thisKey in bucket.list():
	bucket.delete_key(thisKey)


s3.delete_bucket(bucket)


