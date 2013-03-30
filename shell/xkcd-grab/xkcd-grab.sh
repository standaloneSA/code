#!/bin/bash

URL="http://xkcd.com" 

IMGURL=$(curl -o - --stderr /dev/null http://xkcd.com/ | grep 'div id="comic"' -A1 | grep "img src" | awk -F\" '{ print $2 }')

echo "The URL to download is: $IMGURL" 

LOCALFILE=$(echo $IMGURL | cut -d \/ -f 5)

curl $IMGURL -o $LOCALFILE

open /Applications/Preview.app $LOCALFILE




