#!/bin/bash

CMD="iostat -dk 1 1"


# rrdtool create \
#	hostname.mountpoint.rrd \
#	--start <seconds_since_epoch> \
#	--step 300 \
#	DS:rrqms:GAUGE:600:U:U \
#	DS:wrqms:GAUGE:600:U:U \
#  DS:rs:GAUGE:600:U:U \
#	DS:ws:GAUGE:600:U:U \
#	DS:rsec:GAUGE:600:U:U \
#	DS:wsec:GAUGE:600:U:U \
#	DS:avgrq-sz:GAUGE:600:U:U \
#	DS:avgqu-sz:GAUGE:600:U:U \
#	DS:await:GAUGE:600:U:U \
#	DS:svctm:GAUGE:600:U:U \ 
#	DS:percentutil:GAUGE:600:U:U \
#  RRA:MIN:0.5:1:2016


# Get individual mounted FSes: 
# iostat -knxd | grep nfs | awk '{print $1}' | awk -F\/ '{for (i=1;i<NF;i++) printf FS$i; print NL}' | sort  | uniq


