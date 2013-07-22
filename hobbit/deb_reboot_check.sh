#!/bin/bash
#
# Check for /var/run/reboot-required (created by update-notifier)
# and alert iff present
#
# cba@ccs.neu.edu

# Notes for writing this script:
#	Color meaning: http://www.xymon.com/xymon/help/xymon-tips.html#icons
#	Writing scripts: http://www.xymon.com/xymon/help/xymon-tips.html#scripts
#	Valid & reserved colors (see "XYMON MESSAGE SYNTAX" or search color):
#		http://www.xymon.com/xymon/help/manpages/man1/xymon.1.html

# This is an untested draft of a Hobbit/Xymon client-side script

# Thought: Consider use of no-propagate. Do we want this turning hosts yellow/red?
#
# Should we switch from yellow to red for reboot required if
# /var/run/reboot-required is more than N days old? (mtime)
#
# Problem with making color depend on mtime of /var/run/reboot-required is
# that /usr/share/update-notifier/notify-reboot-required writes to
# /var/run/reboot-required every time it is invoked, regardless of whether
# or not it already exists. As such, reboot-required's mtime is not a
# reliable indicator of when it was first created. Would probably need to
# keep track of mtime in a separate file.

COLUMN=reboot
COLOR=CRITICAL
MSG="Something failed running $0 on $(hostname)"
EXIT_STATUS=2
TIME=$(date +%F\ %T\ %z)

/usr/bin/dpkg-query --show update-notifier-common > /dev/null 2>&1

case "$?" in
0)	# update-notifier-common installed, check for /var/run/reboot-required
	# Should probably add error checking on whether or not /var/run/reboot-required can be read (eg: /, /var, /var/run are all readable, executable dirs)
	if [ -e /var/run/reboot-required ]; then
		COLOR=WARNING
		MSG="Updates have been installed which require a reboot to take effect.

Please reboot at your earliest convenience.

/var/run/reboot-required says:

$(/bin/sed 's/^/\t/' /var/run/reboot-required)
"
		EXIT_STATUS=1;
	else
		COLOR=OK
		MSG="No updates which require a reboot to take effect have
triggered update-notifier since last system boot."
		EXIT_STATUS=0;
	fi
	;;
1)	# update-notifier-common is not installed, report clear
	COLOR=WARNING
	MSG="update-notifier-common not installed.

Cannot determine if a reboot is required.

Please install update-notifier-common.
"
	EXIT_STATUS=1
	;;
*)	# Unknow response to dpkg-query (this should never happen), report red:
	COLOR=CRITICAL
	MSG="
Unexpected problem encountered while executing dpkg-query to check for
the presence of the update-notifier-common package. This should not happen.

Cannot complete check. Please check system status.

Aborting plugin execution.
"
	EXIT_STATUS=2
	;;
esac

##$BB $BBDISP "status $MACHINE.$COLUMN $COLOR $TIME

echo "$COLOR - Reboot Status $MSG" ;


exit $EXIT_STATUS
