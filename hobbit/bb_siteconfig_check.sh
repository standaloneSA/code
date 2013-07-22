#!/bin/bash
#
# Check cached results of last siteconfig run and alert on BAD files
#
# cba@ccs.neu.edu

COLUMN=siteconfig
COLOR=red
MSG="Something failed running $0 on $(hostname)"
EXIT_STATUS=100
REPORT_FILE=/var/tmp/siteconfig
STAT=/usr/bin/stat
# Ignore reports more than 176400 seconds (ie: 49 hours (ie: two days + 1 hour's wiggle room)) old:
MAXAGE=176400

# Is siteconfig installed?
if [ -e /usr/sbin/siteconfig ]; then
	# Is there a log of the last siteconfig run?
	if [ -e $REPORT_FILE ]; then
		# Is the report less than $MAXAGE old?
		if [ $(($(/bin/date +%s) - $($STAT -c %Y $REPORT_FILE))) -lt $MAXAGE ]; then
			# Any problems found during last run?
			/bin/grep -q '^	BAD:' $REPORT_FILE
			case "$?" in
			1)	# No problems:
				COLOR=green
				MSG="A-Ok: Last siteconfig run ($($STAT -c %y $REPORT_FILE)) reported no non-compliant files. Report (from $REPORT_FILE) follows:

$(/bin/sed 's/^/\t/' $REPORT_FILE)"
				EXIT_STATUS=0;
				;;
			0)	# Problems found:
				COLOR=yellow
				MSG="Problem: Last siteconfig run ($($STAT -c %y $REPORT_FILE)) reported one or more non-compliant files. Report (from $REPORT_FILE) follows:

$(/bin/sed 's/^/\t/' $REPORT_FILE)"
				EXIT_STATUS=0;
				;;
			*)	# Unknown exit status from grep:
				COLOR=red
				MSG="Unexpected exit code received while grepping for string '^BAD:' in $REPORT_FILE.

Cannot complete check. Please check system status.

Aborting."
	        		EXIT_STATUS=0
				;;
			esac
		else
			COLOR=clear
			MSG="Found report file $REPORT_FILE, but it is more than $MAXAGE seconds old. Data is stale: switching alert status to \"No data.\"

Contents of $REPORT_FILE follow FOR INFORMATIONAL PURPOSES ONLY. You are STRONGLY advised to investigate why the siteconfig cron job has not updated this file.

File contents (file last modified $($STAT -c %y $REPORT_FILE)):

$(/bin/sed 's/^/\t/' $REPORT_FILE)"
	        	EXIT_STATUS=0
		fi
	# No log of last run:
	else
		COLOR=clear
		MSG="$REPORT_FILE not found. Don't know status of last siteconfig run."
	       	EXIT_STATUS=0
	fi
# Siteconfig not installed, can't report:
else
	COLOR=clear
	MSG="/usr/sbin/siteconfig not found.

Assuming siteconfig not installed.

Aborting check. Please install siteconfig."
	EXIT_STATUS=0
fi

$BB $BBDISP "status $MACHINE.$COLUMN $COLOR $TIME

${MSG}
"

exit $EXIT_STATUS
