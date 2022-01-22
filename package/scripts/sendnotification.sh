#!/bin/bash
# sendnotification.sh

# https://forum.synology.com/enu/viewtopic.php?f=32&t=79334&start=15

if [ -z "$VR_Var" ];
	then
		APP_TARGET_PATH="/var/packages/VideoRenamer/target"
		. ${APP_TARGET_PATH}/scripts/var.sh
fi

if [ "$CheckBoxEnableMailNotification" == "1" ] && [[ -f "${VR_APP_LOG_PATH}/VideoRenamed.tmp.log" ]];
	then
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				echo "$(date +"%F %T") : Mail notification activated" >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
		fi
		if [ "$RenamedVideoNbr" -gt "0" ] || [ "$CorruptedVideoNbr" -gt "0" ];
			then
				if [ -e "$VR_VideoStation_Folder/debug" ];
					then
						echo "$(date +"%F %T") : Renamed video Nbr :" $RenamedVideoNbr >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
						echo "$(date +"%F %T") : Corrupted video Nbr :" $CorruptedVideoNbr >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
				fi
				# call the conf file
				. $ConfFilePath
				source /usr/syno/etc/synosmtp.conf;
				host=$(/bin/hostname);
				taskname="VideoRenamer last task";
				headers=`printf "From: %s - %s <%s>\r\n" "$host" "$mailfrom" "$eventuser"`;
				if [ ${#eventmail2} -gt 0 ];
					then
						to=`printf "%s, %s" "$eventmail1" "$eventmail2"`;
					else
						to=$eventmail1;
				fi
				messagebodyresume="$(cat "$VR_APP_TMP_PATH/resume")"
				if [ "$LastMovieNbr" -gt "60" ] || [ "$LastTVShowNbr" -gt "60" ];
					then
						messagebodylog="Too many renamed files to display"
						if [ -e "$VR_VideoStation_Folder/debug" ];
							then
								echo "$(date +"%F %T") : Too many renamed files to display" >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
						fi
					else
						if [ -e "${VR_APP_LOG_PATH}/VideoRenamed.tmp.log" ];
							then
								messagebodylog="$(cat "${VR_APP_LOG_PATH}/VideoRenamed.tmp.log" |sed 's:/:\/:g' |sed "s:':\\\':g" )"
							else
								messagebodylog="no new renamed files"
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : no new renamed files" >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
								fi
						fi
				fi
				if [ -e "$VR_APP_TMP_PATH/START" ];
					then
						status="has failed";
						messagebody="please check out logs (might need to restart the app (see help)";
						if [ -e "$VR_VideoStation_Folder/debug" ];
							then
								echo "$(date +"%F %T") : START still present. application has failed" >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
						fi
					else
						status="has completed successfully";
						messagebody=`printf "%s \n\n%s" "$messagebodyresume" "$messagebodylog"`;
						if [ -e "$VR_VideoStation_Folder/debug" ];
							then
								echo "$(date +"%F %T") : Application has succeded" >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
						fi
				fi
				outcome=`printf "%s on %s %s" "$taskname" "$host" "$status"`;
				subject=`printf "%s %s %s" "$eventsubjectprefix" "$taskname" "$status"`;
				body=`printf "Dear user,\n\n%s\n\n%s\n\nSincerely,\nSynology DiskStation\n\n%s" "$outcome" "$messagebody"`;
				/usr/bin/php -r "mail('$to', '$subject', '$body', '$headers');";
				if [ -e "$VR_VideoStation_Folder/debug" ];
					then
						echo "$(date +"%F %T") : Mail notification activated" >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
						echo "$(date +"%F %T") : Mail to : " $to >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
						echo "$(date +"%F %T") : Mail subject :" $subject >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
						echo "$(date +"%F %T") : Mail body :" $body >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
						echo "$(date +"%F %T") : Mail header :" $headers >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
				fi
			else
			if [ -e "$VR_VideoStation_Folder/debug" ];
				then
					echo "$(date +"%F %T") : No mail sent" >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
			fi
		fi
fi

if [ "$CheckBoxEnableDSMNotification" == "1" ] && [[ -f "${VR_APP_LOG_PATH}/VideoRenamed.tmp.log" ]];
	then
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				echo "$(date +"%F %T") : DSM notification activated" >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
		fi
		if [[ "$RenamedMovieNbr" -gt "0" ]] && [[ "$RenamedTVShowNbr" -eq "0" ]] && [[ "$CorruptedVideoNbr" -eq "0" ]];
			then
				notifytext="${RenamedMovieNbr} movies renamed.";
		fi
		if [[ "$RenamedTVShowNbr" -gt "0" ]] && [[ "$RenamedMovieNbr" -eq "0" ]] && [[ "$CorruptedVideoNbr" -eq "0" ]];
			then
				notifytext="${RenamedTVShowNbr} tvshows renamed.";
		fi
		if [[ "$CorruptedVideoNbr" -gt "0" ]] && [[ "$RenamedMovieNbr" -eq "0" ]] && [[ "$RenamedTVShowNbr" -eq "0" ]];
			then
				notifytext="$CorruptedVideoNbr corrupted files";
		fi
		if [[ "$RenamedMovieNbr" -gt "0" ]] && [[ "$RenamedTVShowNbr" -gt "0" ]] && [[ "$CorruptedVideoNbr" -eq "0" ]];
			then
				notifytext="${RenamedMovieNbr} movies and ${RenamedTVShowNbr} tvshows renamed.";
		fi
		if [[ "$RenamedMovieNbr" -gt "0" ]] && [[ "$CorruptedVideoNbr" -gt "0" ]] && [[ "$RenamedTVShowNbr" -eq "0" ]];
			then
				notifytext="${RenamedMovieNbr} movies renamed and ${CorruptedVideoNbr} corrupted files";
		fi
		if [[ "$RenamedTVShowNbr" -gt "0" ]] && [[ "$CorruptedVideoNbr" -gt "0" ]] && [[ "$RenamedMovieNbr" -eq "0" ]];
			then
				notifytext="${RenamedTVShowNbr} tvshows renamed and ${CorruptedVideoNbr} corrupted files";
		fi
		if [[ "$CorruptedVideoNbr" -gt "0" ]] && [[ "$RenamedTVShowNbr" -gt "0" ]] && [[ "$RenamedMovieNbr" -gt "0" ]];
			then
				notifytext="${RenamedMovieNbr} movies, ${RenamedTVShowNbr} tvshows renamed and ${CorruptedVideoNbr} corrupted files";
		fi
		
		/usr/syno/bin/synodsmnotify "@administrators" "$AppName" "$notifytext";
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				echo "$(date +"%F %T") : DSM notification activated" >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
				echo "$(date +"%F %T") : DSM app name :" $AppName >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
				echo "$(date +"%F %T") : DSM notification text :" $notifytext >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
				if [[ "$CorruptedVideoNbr" -le "0" ]] && [[ "$RenamedTVShowNbr" -le "0" ]] && [[ "$RenamedMovieNbr" -le "0" ]];
					then
						echo "$(date +"%F %T") : No notification sent :" >>"$VR_VideoStation_Folder/VideoRenamer/log/sendnotification.sh.log"
				fi
		fi
fi



