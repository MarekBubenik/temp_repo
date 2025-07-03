#!/bin/bash
#
#

logr_file=/etc/logrotate.d/audit
audit_file=/etc/audit/auditd.conf
cron_file=/etc/cron.daily/logrotate

# Create a logrotate file

if [[ -f $logr_file ]]; then
	cp "$logr_file" "$logr_file".bck
	cp -f $(dirname "$0")/audit "$logr_file"
	echo "Made a backup of $logr_file file and copied a new version..."
else
	cp -f $(dirname "$0")/audit "$logr_file"
	echo "File $logr_file could not be found, continue copying a new version over...."
fi

# Create a new auditd conf file

if [[ -f $audit_file ]]; then
	cp "$audit_file" "$audit_file".bck
	cp -f $(dirname "$0")/auditd.conf "$audit_file"
	echo "Made a backup of $audit_file file and copied a new version..."
else
	cp -f $(dirname "$0")/auditd.conf "$audit_file"
	echo "File $audit_file could not be found, continue copying a new version over...."
fi

# Create a cron job for logrotate

if [[ -f $cron_file ]]; then
	cp "$cron_file" "$cron_file".bck
	cp -f $(dirname "$0")/logrotate "$cron_file"
	echo "Made a backup of $cron_file file and copied a new version..."
else
	cp -f $(dirname "$0")/logrotate "$cron_file"
	echo "File $cron_file could not be found, continue copying a new version over...."
fi

# Restarting auditd service

service auditd restart


