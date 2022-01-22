#!/bin/bash
# var.sh


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

AppName="VideoRenamer"
DisplayName="Video Renamer"
PACKAGE_NAME="$AppName"

if [ -e "$VR_VideoStation_Folder/debug" ] || [ ! -z "$LogExtraction" ];
	then
		if [ ! -e "$VR_VideoStation_Folder/VideoRenamer/log" ];
			then 
				mkdir -p "$VR_VideoStation_Folder/VideoRenamer/log"
				echo "$(date +"%F %T") : $VR_VideoStation_Folder/VideoRenamer/log created" >>"$VR_VideoStation_Folder/VideoRenamer/log/var.sh.log"
		fi
		if [ ! -e "$VR_VideoStation_Folder/VideoRenamer/tmp" ];
			then 
				mkdir -p "$VR_VideoStation_Folder/VideoRenamer/tmp"
				echo "$(date +"%F %T") : $VR_VideoStation_Folder/VideoRenamer/tmp created" >>"$VR_VideoStation_Folder/VideoRenamer/log/var.sh.log"
		fi
		if [ ! -e "$VR_VideoStation_Folder/VideoRenamer/cfg" ];
			then 
				mkdir -p "$VR_VideoStation_Folder/VideoRenamer/cfg"
				echo "$(date +"%F %T") : $VR_VideoStation_Folder/VideoRenamer/cfg created" >>"$VR_VideoStation_Folder/VideoRenamer/log/var.sh.log"
		fi
		chmod -R 777 "$VR_VideoStation_Folder/VideoRenamer/"
		if [ ! -e "/tmp/VideoRenamer/tmp" ];
			then 
				mkdir -p "/tmp/VideoRenamer/tmp"
				echo "$(date +"%F %T") : /tmp/VideoRenamer/tmp created" >>"$VR_VideoStation_Folder/VideoRenamer/log/var.sh.log"
		fi
		if [ ! -e "/tmp/VideoRenamer/log" ];
			then 
				mkdir -p "/tmp/VideoRenamer/log"
				echo "$(date +"%F %T") : /tmp/VideoRenamer/log created" >>"$VR_VideoStation_Folder/VideoRenamer/log/var.sh.log"
		fi
		if [ ! -e "/tmp/VideoRenamer/cfg" ];
			then 
				mkdir -p "/tmp/VideoRenamer/cfg"
				echo "$(date +"%F %T") : /tmp/VideoRenamer/cfg created" >>"$VR_VideoStation_Folder/VideoRenamer/log/var.sh.log"
		fi
		chmod -R 777 "/tmp/VideoRenamer/"
fi

VIDEO_METADATA_DB="video_metadata"
PSQL="/usr/bin/psql"
BASH_PATH="/bin/bash"
SU_VIDEO_STATION="/bin/su -l VideoStation -s ${BASH_PATH}"
NOW=$(date +"%F") # declaration de la date - ne pas changer
if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		echo "$(date +"%F %T") : postgresql var is set" >>"$VR_VideoStation_Folder/VideoRenamer/log/var.sh.log"
fi

ExecSqlCommand()
{
	#original conf
	#${PSQL} -U postgres video_metadata -t -c "$1"
	${PSQL} -U postgres video_metadata -q -A -t -c "$1"
}
if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		echo "$(date +"%F %T") : sqlcommand is set" >>"$VR_VideoStation_Folder/VideoRenamer/log/var.sh.log"
fi

NOW=$(date +"%F") # declaration de la date - ne pas changer

ExecSqlCommand "SELECT last_renamed_date FROM video_file WHERE id = 0"
Ret=$?
if [ "$Ret" -eq "0" ];
	then
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				echo "$(date +"%F %T") : last_renamed_date exist continue DB request" >>"$VR_VideoStation_Folder/VideoRenamer/log/var.sh.log"
		fi
		#check number of movies
		RenamedMovieNbr="$(ExecSqlCommand "SELECT COUNT(*) FROM video_file a, movie b WHERE last_renamed_date = '$NOW' AND a.mapper_id=b.mapper_id;")"
		RenamedMovieNbr=$(echo $RenamedMovieNbr)
		#check number of tvshows
		RenamedTVShowNbr="$(ExecSqlCommand "SELECT COUNT(*) FROM tvshow a, video_file c, tvshow_episode d WHERE last_renamed_date = '$NOW' AND a.id=d.tvshow_id AND c.mapper_id=d.mapper_id;")"
		RenamedTVShowNbr=$(echo $RenamedTVShowNbr)
		#renamed video count
		RenamedVideoNbr="$(ExecSqlCommand "SELECT COUNT(*) FROM video_file WHERE last_renamed_date = '$NOW';")"
		RenamedVideoNbr=$(echo $RenamedVideoNbr)
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				echo "$(date +"%F %T") : VideoRenamer DB request OK" >>"$VR_VideoStation_Folder/VideoRenamer/log/var.sh.log"
		fi
fi
#corrupted video count
CorruptedVideoNbr="$(ExecSqlCommand "SELECT COUNT(*) FROM video_file WHERE resolutionx='0' AND resolutiony='0';")"
CorruptedVideoNbr=$(echo $CorruptedVideoNbr)
if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		echo "$(date +"%F %T") : naming is set" >>"$VR_VideoStation_Folder/VideoRenamer/log/var.sh.log"
fi


if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		echo "$(date +"%F %T") : renaming count result from DB" >>"$VR_VideoStation_Folder/VideoRenamer/log/var.sh.log"
fi



#[App_Conf]
#LOG_NAME=VideoRenamer # nom du fichier log
#VR_APP_LOG_PATH="/$VideoStationVolume/video/" # chemin du log

JOB_FILENAME="crontab.job"
#JOB_TIME="jobtime.cfg"

APP_TARGET_PATH="/var/packages/$AppName/target"


#ConfFilePath="/$VideoStationVolume/video/VideoRenamer.cfg"
ConfFilePath="${APP_TARGET_PATH}/cfg/VideoRenamer.cfg"
#DetectResolution="/var/packages/$AppName/target/plugins/DetectResolution"
Debug_PATH="/$VideoStationVolume/video/"
KillSwitchPath="/$VideoStationVolume/video/"



VR_Generated_Log_Dest="/tmp/$AppName"
VR_APP_BIN_PATH="${APP_TARGET_PATH}/bin"
VR_APP_CFG_PATH="${APP_TARGET_PATH}/cfg"
VR_APP_ETC_PATH="${APP_TARGET_PATH}/etc"
VR_APP_LOG_PATH="${APP_TARGET_PATH}/log"
VR_APP_SCRIPTS_PATH="${APP_TARGET_PATH}/scripts"
VR_APP_TMP_PATH="${APP_TARGET_PATH}/tmp"
VR_APP_UI_PATH="${APP_TARGET_PATH}/ui"
#VR_Var="1"


#APP_TMP_PATH="$VR_APP_TMP_PATH"
JOB_PATH="$VR_APP_CFG_PATH/"

MAIN_SCRIPT_FULL_PATH="/var/packages/VideoRenamer/target/scripts/videorenamer.sh"
timer_scriptname=$(echo "$MAIN_SCRIPT_FULL_PATH" | sed 's/ $//;s#.*/bin/bash ##')
timer_delete=$(echo "$timer_scriptname" | sed 's/.*\///g')


#ERROR_LOG_PATH="$VR_APP_TMP_PATH"
ErrorLogName="error"

VIDEOSTATION_PKGNAME="${AppName}"
PACKAGE_DIR="/var/packages/${VIDEOSTATION_PKGNAME}"

# to delete
#LOG_PATH_ORIGIN="$VR_APP_LOG_PATH/" # chemin du log
#LOG_PATH="$LOG_PATH_ORIGIN"

# longuest extension known
MaxExtensionLengh=".vsmeta"




