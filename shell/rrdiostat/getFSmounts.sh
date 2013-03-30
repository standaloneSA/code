#!/bin/bash

mount | grep ^/dev/ | awk '{print $1}' | awk -F\/ '{printf $2; for (i=3;i<=NF;i++) printf "_" $i; print NL}'
mount | grep -v 'dev\|none'  | awk '{print $1}' | awk -F\/ '{for (i=1;i<NF;i++) printf FS$i; print NL}' | sort | uniq | cut -d \: -f 2 | awk -F\/ '{printf $2; for (i=3;i<=NF;i++) printf "_" $i; print NL}'


