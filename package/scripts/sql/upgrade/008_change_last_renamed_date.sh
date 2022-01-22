#!/bin/sh
# Update 008
#script_name=$(basename -- "$0")
script_name="008_change_last_renamed_date"
PSQL_UPDATE_VER="008"

# check where Video Station is installed
COUNTER=1
while [ $COUNTER -lt 100 ]; do
	if [ -e "/volume$COUNTER/@appstore/VideoStation" ]; 
		then 
			VideoStationVolume="volume$COUNTER"
			break
	fi
	let COUNTER=COUNTER+1 
done
VR_VideoStation_Folder="/$VideoStationVolume/video"

PSQL="/usr/bin/psql"

ExecSqlCommand()
{
	${PSQL} -U postgres video_metadata -c "$1" > /dev/null 2>&1
}

if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		echo "$(date +"%F %T") : Update $PSQL_UPDATE_VER" >> "$VR_VideoStation_Folder/VideoRenamer/log/$script_name.sh.log"
fi
ExecSqlCommand "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'video_file' AND column_name = 'last_renamed_date';" | grep ' date'
Ret=$?
if [ $Ret = 0 ]; 
	then
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				echo "$(date +"%F %T") : Updating DB" >> "$VR_VideoStation_Folder/VideoRenamer/log/$script_name.sh.log"
		fi
		Script="/var/packages/VideoRenamer/target/scripts/sql/upgrade/$script_name.pgsql"
		${PSQL} -U postgres video_metadata < ${Script}
		if [ $? != 0 ];
			then
				if [ -e "$VR_VideoStation_Folder/debug" ];
					then
						echo "$(date +"%F %T") : Failed to alter video_file table in video_metadata" >> "$VR_VideoStation_Folder/VideoRenamer/log/$script_name.sh.log"
						echo "$(date +"%F %T") : Update $PSQL_UPDATE_VER failed" >> "$VR_VideoStation_Folder/VideoRenamer/log/$script_name.sh.log"
					else
						echo "$(date +"%F %T") : Update $PSQL_UPDATE_VER installed" >> "$VR_VideoStation_Folder/VideoRenamer/log/$script_name.sh.log"
				fi
			exit
		fi
	else
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				echo "$(date +"%F %T") : Update $PSQL_UPDATE_VER already installed" >> "$VR_VideoStation_Folder/VideoRenamer/log/$script_name.sh.log"
		fi
fi