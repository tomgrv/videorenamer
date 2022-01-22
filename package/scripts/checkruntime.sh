#!/bin/ash

if [ -z "$VR_Var" ];
	then
		APP_TARGET_PATH="/var/packages/VideoRenamer/target"
		. ${APP_TARGET_PATH}/scripts/var.sh
fi

# check that schedule time is a good number (entier entre 0 et 23)

# check that there is a time in crontab

# check that there is a good time in cronjob

#check that there is a good time in taskjob

