#!/bin/bash
# delemptyfolder.sh

if [ -z "$VR_Var" ];
	then
		APP_TARGET_PATH="/var/packages/VideoRenamer/target"
		. ${APP_TARGET_PATH}/scripts/var.sh
fi


#find all lines in video_file with lib_path = null
ExecSqlCommand "SELECT DISTINCT lib_path FROM video_file WHERE lib_path is not null" | while read ENTRY 
	do
		#find /volume1/Temp/d/ -type d -empty -ls >dirlist.txt

		# delete empty folders from LIB_PATH
		
		# DEBUG
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				if [[ $(find $ENTRY/ -type d -empty -print | wc -l) != "0" ]];
					then
						find $ENTRY/ -type d -empty -delete -print >>"$VR_VideoStation_Folder/VideoRenamer/log/delemptyfolder.sh.log"
						finderr=$?
						
						echo "$(date +"%F %T") : delemptyfolder : empty folders in $ENTRY deleted" >>"$VR_VideoStation_Folder/VideoRenamer/log/delemptyfolder.sh.log"
						echo "---------------------------------------------" >>"$VR_VideoStation_Folder/VideoRenamer/log/delemptyfolder.sh.log"
					fi
			else
				find $ENTRY/ -type d -empty -delete
		fi
	done
	
	