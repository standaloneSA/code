#!/usr/bin/env python

import boto

s3 = boto.connect_s3()

key = s3.get_bucket('media.thecircus.org').get_key('examples/first_file.csv')
key.get_contents_to_filename('/Users/bandman/c.out')


