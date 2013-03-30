#!/usr/bin/env python

import boto

s3 = boto.connect_s3()

bucket = s3.create_bucket('media.thecircus.org')

key = bucket.new_key('examples/first_file.csv')
key.set_contents_from_filename('/Users/bandman/b.out')
key.set_acl('public-read')




