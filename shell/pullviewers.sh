#!/bin/bash

if [ "$1" == "" ] ; then 
   print "Usage: $0 URL"
   exit
fi

URL="$1"


VIEWERS=`wget -O - $URL 2>/dev/null  | grep "In Crowd" -B1 | head -n 1 | cut -d \> -f 2 | cut -d \< -f 1| sed 's/,//g'`


echo $VIEWERS


