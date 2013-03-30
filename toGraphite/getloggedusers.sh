#!/bin/bash

curUsers=`who | wc -l`
now=`date +%s`
echo "CCIS.systems.${HOSTNAME}.loggedInUsers	$curUsers $now"


