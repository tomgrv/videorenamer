#!/bin/sh
#video_metadata.sh
# add sql tables for Video Renamer

#VIDEO_METADATA_DB="video_metadata"

BASH_PATH="/bin/bash"
SU_VIDEO_STATION="/bin/su -l VideoStation -s ${BASH_PATH}"

#PG_SCRIPT="/var/packages/VideoRenamer/target/scripts/sql/video_metadata.pgsql"
#PG_UPDATE_SCRIPT="/var/packages/VideoRenamer/target/scripts/sql/upgrade/video_file_update_01.pgsql"
UPGRADE_DIR="/var/packages/VideoRenamer/target/scripts/sql/upgrade"


#CREATE_DB="/usr/bin/createdb"
#PSQL="/usr/bin/psql"



upgrades=`find $UPGRADE_DIR -name "*.sh" | sort`
for ThisArg in $upgrades;
do
	#${SU_VIDEO_STATION} -c ${ThisArg}
	.${ThisArg}
	if [ $? -eq 0 ]; then
		#this function will be used to rescan all files to updae DB
		#NeedReindex=1
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				echo "$(date +"%F %T") : sql update : $ThisArg" >> "$VR_VideoStation_Folder/VideoRenamer/log/video_metadata.sh.log"
		fi
	fi
done
