#!/bin/bash
set -eo pipefail

STATUS=0
PROCESS_NAME="nr-uesoftmodem"


if [ $(pgrep $PROCESS_NAME | wc -l) -eq 0 ]; 
then 
	STATUS=1
else	
	if [ $(ifconfig | grep -c "12.1.1.*") -eq 0 ];
	then 
		STATUS=1
	fi
fi

exit $STATUS