#!/bin/sh


if [ -z "$VR_Var" ];
	then
		APP_TARGET_PATH="/var/packages/VideoRenamer/target"
		. ${APP_TARGET_PATH}/scripts/var.sh
fi

# remove the cron task
timer_scriptname=$(echo "$MAIN_SCRIPT_FULL_PATH" | sed 's/ $//;s#.*/bin/bash ##')
timer_delete=$(echo "$timer_scriptname" | sed 's/.*\///g')
sed -i "/"$timer_delete"/d" "/etc/crontab"


#MinuteToRun="$(grep 'hour: ' "${JOB_PATH}$JOB_TIME")"
#MinuteToRun="${MinuteToRun:8}"
#HourToRun="$(grep 'hour: ' "${JOB_PATH}$JOB_TIME")"
#HourToRun="${HourToRun:6}"
#DayOfMonthToRun="$(grep 'hour: ' "${JOB_PATH}$JOB_TIME")"
#DayOfMonthToRun="${DayOfMonthToRun:14}"
#MonthToRun="$(grep 'hour: ' "${JOB_PATH}$JOB_TIME")"
#MonthToRun="${MonthToRun:7}"
#DayOfWeekToRun="$(grep 'hour: ' "${JOB_PATH}$JOB_TIME")"
#DayOfWeekToRun="${DayOfWeekToRun:13}"

echo "$MinuteToRun	$HourToRun	$DayOfMonthToRun	$MonthToRun	$DayOfWeekToRun	root	$MAIN_SCRIPT_FULL_PATH" >>/etc/crontab
#cat "$JOB_PATH$JOB_FILENAME" >>/etc/crontab

/usr/syno/sbin/synoservicectl --reload crond