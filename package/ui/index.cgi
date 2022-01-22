#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/syno/bin:/usr/syno/sbin

if [ -z "$VR_Var" ];
	then
		APP_TARGET_PATH="/var/packages/VideoRenamer/target"
		. ${APP_TARGET_PATH}/scripts/var.sh
fi

functiongetconf ()
{
	if [ -e "${JOB_PATH}$JOB_FILENAME" ];
		then
			#MinuteToRun="$(cut -f1 "$JOB_PATH$JOB_FILENAME")"
			HourToRun="$(cut -f2 "$JOB_PATH$JOB_FILENAME")"
			#DayOfMonthToRun="$(cut -f3 "$JOB_PATH$JOB_FILENAME")"
			#MonthToRun="$(cut -f4 "$JOB_PATH$JOB_FILENAME")"
			#DayOfWeekToRun="$(cut -f5 "$JOB_PATH$JOB_FILENAME")"
		else
			HourToRun="1"
	fi

	# call the conf file
	. $ConfFilePath &&


	LogMaxSizeValue="$LogMaxSize"
	if [ "$CheckBoxEnableCycleRun" == "1" ];
		then 
			CheckBoxEnableCycleRunValue="checked"
			HourToRun="0"
	fi
	if [ "$CheckBoxEnableMailNotification" == "1" ];
		then 
			CheckBoxEnableMailNotificationValue="checked"
	fi
	if [ "$CheckBoxEnableDSMNotification" == "1" ];
		then 
			CheckBoxEnableDSMNotificationValue="checked"
	fi
	if [ "$EnableAddYear" == "1" ];
		then 
			CheckBoxEnableAddYearValue="checked"
	fi
	if [ "$EnableAddResolutionNaming" == "1" ];
		then 
			EnableAddResolutionNamingValue="checked"
	fi
	if [ "$EnableAddResolution" == "1" ];
		then 
			EnableAddResolutionValue="checked"
	fi
	if [ "$EnableAddCodecs" == "1" ];
		then 
			EnableAddCodecsValue="checked"
	fi
	if [ "$DeleteNotAdvisedSpecialCharacters" == "1" ];
		then 
			DeleteNotAdvisedSpecialCharactersValue="checked"
	fi
	if [ "$DeleteSpecialLetters" == "1" ];
		then 
			DeleteSpecialLettersValue="checked"
	fi
	if [ "$DeleteAuthorizedSpecialCharacters" == "1" ];
		then 
			DeleteAuthorizedSpecialCharactersValue="checked"
	fi
	if [ "$DeleteWhiteSpace" == "1" ];
		then 
			DeleteWhiteSpaceValue="checked"
	fi
	if [ "$VideoNotRenamedLog" == "1" ];
		then 
			VideoNotRenamedLogValue="checked"
	fi
	if [ "$VideoRenamedLog" == "1" ];
		then 
			VideoRenamedLogValue="checked"
	fi
	if [ "$MakeFolder" == "1" ];
		then 
			MakeFolderValue="checked"
	fi
	if [ "$movieyearfolder" == "1" ];
		then 
			movieyearfolderValue="checked"
	fi
	if [ "$tvshowyearfolder" == "1" ];
		then 
			tvshowyearfolderValue="checked"
	fi
	if [ "$delemptyfolder" == "1" ];
		then 
			delemptyfolderValue="checked"
	fi

}

functiongetconf
echo "Content-type: text/html"
echo
echo '
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link type="text/css" rel="stylesheet" media="all" title="CSS" href="style.css" />
	<script type="text/javascript" src="javascript/default.js" language="Javascript"></script>
	<title>Video Renamer</title>
</head>
<body>






<div id="conteneur">
	<nav>
		<ul class="tab">
			<li><a href="#configuration" id="defaultOpen">Configuration</a></li>
			<li><a href="#resume">Resume</a></li>
			<li><a href="#help">Help</a></li>
			<li><a href="#history">History</a></li>
		</ul>
	</nav>'
	# set the default page
	echo '
	<script>
		document.getElementById("defaultOpen").click();
	</script>'

	# Section CONFIGURATION
	echo '
	<section id="configuration" class="tabcontent">
		<form method=GET action="index.cgi#configuration">
			<table nowrap>
			
				<p><tr><td><b>App configuration</b></br>
				
				Your videos will be renamed every day at: <input id="id_HourToRun" type="number" name="NewTime" value='$HourToRun' size="2" step="1" min="0" max="23"></br>
				
				<input id="id_CheckBoxEnableCycleRun" type="checkbox" name="CheckBoxEnableCycleRun" '$CheckBoxEnableCycleRunValue'>Cycle Run (runs every 6 hours - 0,6,12,18)</br>
				Manually run application <input id="id_ManualRunButton" type="submit" name="ManualRunButton" value="Run" /></br></td></tr></p>'
				ManualRun=`echo "$QUERY_STRING" | sed -n 's/^.*ManualRunButton=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
				if [ "$ManualRun" == "Run" ];
					then
						is_renamed_true_Nbr="$(${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'select count(*) from video_file where is_renamed = true;'")"
						#is_renamed_true_Nbr="$(echo $is_renamed_true_Nbr | cut -d "|" -f 2)"
						if [[ "$is_renamed_true_Nbr" = "0" ]];
							then 
								echo '
								<tr><td><center><p style="color:red;">First run can not be manual</p></center></td></tr>
								<tr><td><center><p style="color:red;">please wait for first automatique cycle</p></center></td></tr>'
							else
								. ${APP_TARGET_PATH}/scripts/videorenamer.sh
						fi
						
				fi
				echo '
				
				<p><tr><td><b>Notification</b></br>
				
				<input id="id_CheckBoxEnableMailNotification" type="checkbox" name="CheckBoxEnableMailNotification" '$CheckBoxEnableMailNotificationValue'>Mail notification</br>
				
				<input id="id_CheckBoxEnableDSMNotification" type="checkbox" name="CheckBoxEnableDSMNotification" '$CheckBoxEnableDSMNotificationValue'>DSM notification</br></br></td></tr></p>
				
				<p><tr><td><b>Filename configuration</b></br>
				
				<input id="id_CheckBoxEnableAddYear" type="checkbox" name="CheckBoxEnableAddYear" '$CheckBoxEnableAddYearValue'>Add year in filename (Recommended)</br>
				
				<font size="2"> - output exemple "movietitle (2017).mkv"</font></br>
				
				<input id="id_EnableAddResolutionNaming" type="checkbox" name="CheckBoxEnableAddResolutionNaming" '$EnableAddResolutionNamingValue'>Add resolution standard name to filename</br>
				
				<font size="2"> - output exemple "movietitle - 1080p.mkv"</font></br>
				
				<input id="id_EnableAddResolution" type="checkbox" name="CheckBoxEnableAddResolution" '$EnableAddResolutionValue'>Add resolution to filename</br>
				
				<font size="2"> - output exemple "movietitle - 1920x1080.mkv"</font></br>
				
				<input id="id_EnableAddCodecs" type="checkbox" name="CheckBoxEnableAddCodecs" '$EnableAddCodecsValue'>Add Codecs to filename</br>
				
				<font size="2"> - output exemple "movietitle - mpeg4-mp3.mkv"</font></br>
				
				<input id="id_DeleteNotAdvisedSpecialCharacters" type="checkbox" name="CheckBoxDeleteNotAdvisedSpecialCharacters" '$DeleteNotAdvisedSpecialCharactersValue'>Remove special character from filename (Recommended)</br>
				
				<font size="2"> - output exemple "movie:title?.mkv" will become "movie title .mkv"</font></br>
				
				<input id="id_DeleteSpecialLetters" type="checkbox" name="CheckBoxDeleteSpecialLetters" '$DeleteSpecialLettersValue'>Remove special letters from filename</br>
				
				<font size="2"> - output exemple "mövïétïtlè.mkv" will become "movietitle.mkv"</font></br>
				
				<input id="id_DeleteAuthorizedSpecialCharacters" type="checkbox" name="CheckBoxDeleteAuthorizedSpecialCharacters" '$DeleteAuthorizedSpecialCharactersValue'>Remove authorized special character from filename (Not recommended)</br>
				
				<font size="2"> - output exemple "#movie*title.mkv" will become "movie-title.mkv"</font></br>
				
				<input id="id_DeleteWhiteSpace" type="checkbox" name="CheckBoxDeleteWhiteSpace" '$DeleteWhiteSpaceValue'>Remove space and/or blanks from filename</br>
				
				<font size="2"> - output exemple "movie title.mkv" will become "movie.title.mkv"</font></br>
				
				<input id="id_MakeFolder" type="checkbox" name="CheckBoxMakeFolder" '$MakeFolderValue'>Puts your video in corresponding folder</br>
				
				<font size="2"> - output folder will look like "movietitle (year)" or "tvshowtitle/season number"</font></br>
				
				<input id="id_tvshowyearfolder" type="checkbox" name="CheckBoxtvshowyearfolder" '$tvshowyearfolderValue'>Puts your tvshows in folder sorted by decades</br>
				
				<font size="2"> - output folder will look like "decade/tvshowtitle (year)/"</font></br>
				
				<input id="id_movieyearfolder" type="checkbox" name="CheckBoxmovieyearfolder" '$movieyearfolderValue'>Puts your movies in folder sorted by decades</br>
				
				<font size="2"> - output folder will look like "decade/movietitle (year)/"</font></br>
				
				<input id="id_delemptyfolder" type="checkbox" name="CheckBoxdelemptyfolder" '$delemptyfolderValue'>Deletes empty folders found in libraries</br>
				
				</td></tr></p>'
				
				
				# check if app running
				if [ ! -e "$VR_APP_TMP_PATH/START" ];
					then 
						# default value or last value added
						echo '
						<script>
							function Function_Save_Conf() {
								if (typeof NewTime === undefined) {
									document.getElementById("id_HourToRun").value = '$HourToRun';
								} else {
									document.getElementById("id_HourToRun").value = NewTime;
								}
							}
						</script>

						<tr><td><input id="id_SaveButton" type="submit" name="SaveButton" onclick="Function_Save_Conf()" value="Save" /></td></tr>'
				fi
				echo '
			</table>
		</form>'

	#echo $QUERY_STRING >/volume1/Dev/dev/test.log
	HourToRun=`echo "$QUERY_STRING" | sed -n 's/^.*NewTime=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxEnableCycleRun=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxEnableCycleRun=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	
	LogMaxSizeValue=`echo "$QUERY_STRING" | sed -n 's/^.*LogMaxSizeInput=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	
	CheckBoxEnableMailNotification=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxEnableMailNotification=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxEnableDSMNotification=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxEnableDSMNotification=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	
	CheckBoxEnableAddYear=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxEnableAddYear=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxEnableAddResolutionNaming=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxEnableAddResolutionNaming=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxEnableAddResolution=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxEnableAddResolution=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxEnableAddCodecs=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxEnableAddCodecs=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxDeleteNotAdvisedSpecialCharacters=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxDeleteNotAdvisedSpecialCharacters=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxDeleteSpecialLetters=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxDeleteSpecialLetters=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxDeleteAuthorizedSpecialCharacters=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxDeleteAuthorizedSpecialCharacters=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxDeleteWhiteSpace=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxDeleteWhiteSpace=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxVideoNotRenamedLog=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxVideoNotRenamedLog=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxVideoRenamedLog=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxVideoRenamedLog=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxMakeFolder=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxMakeFolder=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxmovieyearfolder=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxmovieyearfolder=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxtvshowyearfolder=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxtvshowyearfolder=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	CheckBoxdelemptyfolder=`echo "$QUERY_STRING" | sed -n 's/^.*CheckBoxdelemptyfolder=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
	
	SavedConf=`echo "$QUERY_STRING" | sed -n 's/^.*SaveButton=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`


	# If no search arguments, pass.
	#if [ "${parm[2]}" == "SaveButton" ] || [ "${parm[3]}" == "Save" ];
	if [ "$SavedConf" == "Save" ];
		then
			# extract the data you are looking for with sed:
			
			# delete old time line
			#timer_hourline=$(echo "hour: " | sed 's/ $//;s#.*/bin/bash ##')
			#timer_hourlinedelete=$(echo "$timer_hourline" | sed 's/.*\///g')
			#sed -i "/"$timer_hourlinedelete"/d" "$JOB_PATH$JOB_TIME"
			# add new time line
			#echo "hour: $HourToRun" >> "$JOB_PATH$JOB_TIME" # (from 0 to 23)
			#remove crontask
			sed -i "/"$timer_delete"/d" "/etc/crontab"
			# new cron task
			#echo "$MinuteToRun	$HourToRun	$DayOfMonthToRun	$MonthToRun	$DayOfWeekToRun	root	$MAIN_SCRIPT_FULL_PATH" > "$JOB_PATH$JOB_FILENAME"
			if [ "$CheckBoxEnableCycleRun" == "on" ];
				then
					HourToRun="*/6"
					sed -i -e 's/CheckBoxEnableCycleRun=.*/CheckBoxEnableCycleRun=1/g' "$ConfFilePath"
				else
					sed -i -e 's/CheckBoxEnableCycleRun=.*/CheckBoxEnableCycleRun=0/g' "$ConfFilePath"
			fi
			echo "0	$HourToRun	*	*	*	root	$MAIN_SCRIPT_FULL_PATH" > "$JOB_PATH$JOB_FILENAME"
			cat "$JOB_PATH$JOB_FILENAME" >>/etc/crontab
			#cat "$MinuteToRun	$HourToRun	$DayOfMonthToRun	$MonthToRun	$DayOfWeekToRun	root	$MAIN_SCRIPT_FULL_PATH" >>/etc/crontab
			/usr/syno/sbin/synoservicectl --reload crond 2>&1 >/dev/null
			if [ "$CheckBoxEnableMailNotification" == "on" ];
				then
					sed -i -e 's/EnableMailNotification=.*/EnableMailNotification=1/g' "$ConfFilePath"
				else
					sed -i -e 's/EnableMailNotification=.*/EnableMailNotification=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxEnableDSMNotification" == "on" ];
				then
					sed -i -e 's/EnableDSMNotification=.*/EnableDSMNotification=1/g' "$ConfFilePath"
				else
					sed -i -e 's/EnableDSMNotification=.*/EnableDSMNotification=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxEnableAddYear" == "on" ];
				then
					sed -i -e 's/EnableAddYear=.*/EnableAddYear=1/g' "$ConfFilePath"
				else
					sed -i -e 's/EnableAddYear=.*/EnableAddYear=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxEnableAddResolutionNaming" == "on" ];
				then
					sed -i -e 's/EnableAddResolutionNaming=.*/EnableAddResolutionNaming=1/g' "$ConfFilePath"
				else
					sed -i -e 's/EnableAddResolutionNaming=.*/EnableAddResolutionNaming=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxEnableAddResolution" == "on" ];
				then
					sed -i -e 's/EnableAddResolution=.*/EnableAddResolution=1/g' "$ConfFilePath"
				else
					sed -i -e 's/EnableAddResolution=.*/EnableAddResolution=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxEnableAddCodecs" == "on" ];
				then
					sed -i -e 's/EnableAddCodecs=.*/EnableAddCodecs=1/g' "$ConfFilePath"
				else
					sed -i -e 's/EnableAddCodecs=.*/EnableAddCodecs=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxDeleteNotAdvisedSpecialCharacters" == "on" ];
				then
					sed -i -e 's/DeleteNotAdvisedSpecialCharacters=.*/DeleteNotAdvisedSpecialCharacters=1/g' "$ConfFilePath"
				else
					sed -i -e 's/DeleteNotAdvisedSpecialCharacters=.*/DeleteNotAdvisedSpecialCharacters=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxDeleteSpecialLetters" == "on" ];
				then
					sed -i -e 's/DeleteSpecialLetters=.*/DeleteSpecialLetters=1/g' "$ConfFilePath"
				else
					sed -i -e 's/DeleteSpecialLetters=.*/DeleteSpecialLetters=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxDeleteAuthorizedSpecialCharacters" == "on" ];
				then
					sed -i -e 's/DeleteAuthorizedSpecialCharacters=.*/DeleteAuthorizedSpecialCharacters=1/g' "$ConfFilePath"
				else
					sed -i -e 's/DeleteAuthorizedSpecialCharacters=.*/DeleteAuthorizedSpecialCharacters=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxDeleteWhiteSpace" == "on" ];
				then
					sed -i -e 's/DeleteWhiteSpace=.*/DeleteWhiteSpace=1/g' "$ConfFilePath"
				else
					sed -i -e 's/DeleteWhiteSpace=.*/DeleteWhiteSpace=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxVideoNotRenamedLog" == "on" ];
				then
					sed -i -e 's/VideoNotRenamedLog=.*/VideoNotRenamedLog=1/g' "$ConfFilePath"
				else
					sed -i -e 's/VideoNotRenamedLog=.*/VideoNotRenamedLog=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxVideoRenamedLog" == "on" ];
				then
					sed -i -e 's/VideoRenamedLog=.*/VideoRenamedLog=1/g' "$ConfFilePath"
				else
					sed -i -e 's/VideoRenamedLog=.*/VideoRenamedLog=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxmovieyearfolder" == "on" ];
				then
					sed -i -e 's/movieyearfolder=.*/movieyearfolder=1/g' "$ConfFilePath"
					# on active aussi le makefolder
					sed -i -e 's/MakeFolder=.*/MakeFolder=1/g' "$ConfFilePath"
				else
					sed -i -e 's/movieyearfolder=.*/movieyearfolder=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxtvshowyearfolder" == "on" ];
				then
					sed -i -e 's/tvshowyearfolder=.*/tvshowyearfolder=1/g' "$ConfFilePath"
					# on active aussi le makefolder
					sed -i -e 's/MakeFolder=.*/MakeFolder=1/g' "$ConfFilePath"
				else
					sed -i -e 's/tvshowyearfolder=.*/tvshowyearfolder=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxdelemptyfolder" == "on" ];
				then
					sed -i -e 's/delemptyfolder=.*/delemptyfolder=1/g' "$ConfFilePath"
				else
					sed -i -e 's/delemptyfolder=.*/delemptyfolder=0/g' "$ConfFilePath"
			fi
			if [ "$CheckBoxMakeFolder" == "on" ];
				then
					sed -i -e 's/MakeFolder=.*/MakeFolder=1/g' "$ConfFilePath"
				else
					sed -i -e 's/MakeFolder=.*/MakeFolder=0/g' "$ConfFilePath"
			fi
			sed -i -e "s/LogMaxSize=.*/LogMaxSize=$LogMaxSizeValue/g" "$ConfFilePath"
			if [ ! -e "$VR_APP_TMP_PATH/rescan" ];
				then
					echo "rescan" > "$VR_APP_TMP_PATH/rescan"
			fi
			synoacltool -enforce-inherit "$ConfFilePath"
			#update DB to reset all renamed_path
			#${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE  video_file SET renamed_path = NULL;"
			#echo $EnableAddCodecs $CheckBoxEnableAddCodecs
			#if ([[ "$EnableAddCodecs" == "1" ]] && [[ "$CheckBoxEnableAddCodecs" != "on" ]]) || ([[ "$EnableAddCodecs" == "0" ]] && [[ "$CheckBoxEnableAddCodecs" == "on" ]]);
			if ([[ "$EnableAddYear" == "1" ]] && [[ "$CheckBoxEnableAddYear" != "on" ]]) || ([[ "$EnableAddYear" == "0" ]] && [[ "$CheckBoxEnableAddYear" == "on" ]]) || ([[ "$EnableAddResolutionNaming" == "1" ]] && [[ "$CheckBoxEnableAddResolutionNaming" != "on" ]]) || ([[ "$EnableAddResolutionNaming" == "0" ]] && [[ "$CheckBoxEnableAddResolutionNaming" == "on" ]]) || ([[ "$EnableAddCodecs" == "1" ]] && [[ "$CheckBoxEnableAddCodecs" != "on" ]]) || ([[ "$EnableAddCodecs" == "0" ]] && [[ "$CheckBoxEnableAddCodecs" == "on" ]]) || ([[ "$EnableAddResolution" == "1" ]] && [[ "$CheckBoxEnableAddResolution" != "on" ]]) || ([[ "$EnableAddResolution" == "0" ]] && [[ "$CheckBoxEnableAddResolution" == "on" ]]) || ([[ "$EnableAddResolution" == "1" ]] && [[ """$CheckBoxEnableAddResolution" != "on" ]]) || ([[ "$EnableAddResolution" == "0" ]] && [[ "$CheckBoxEnableAddResolution" == "on" ]]) || ([[ "$DeleteNotAdvisedSpecialCharacters" == "1" ]] && [[ "$CheckBoxDeleteNotAdvisedSpecialCharacters" != "on" ]]) || ([[ "$DeleteNotAdvisedSpecialCharacters" == "0" ]] && [[ "$CheckBoxDeleteNotAdvisedSpecialCharacters" == "on" ]]) || ([[ "$DeleteSpecialLetters" == "1" ]] && [[ "$CheckBoxDeleteSpecialLetters" != "on" ]]) || ([[ "$DeleteSpecialLetters" == "0" ]] && [[ "$CheckBoxDeleteSpecialLetters" == "on" ]]) || ([[ "$DeleteAuthorizedSpecialCharacters" == "1" ]] && [[ "$CheckBoxDeleteAuthorizedSpecialCharacters" != "on" ]]) || ([[ "$DeleteAuthorizedSpecialCharacters" == "0" ]] && [[ "$CheckBoxDeleteAuthorizedSpecialCharacters" == "on" ]]) || ([[ "$DeleteWhiteSpace" == "1" ]] && [[ "$CheckBoxDeleteWhiteSpace" != "on" ]]) || ([[ "$DeleteWhiteSpace" == "0" ]] && [[ "$CheckBoxDeleteWhiteSpace" == "on" ]]) || ([[ "$movieyearfolder" == "1" ]] && [[ "$CheckBoxmovieyearfolder" != "on" ]]) || ([[ "$movieyearfolder" == "0" ]] && [[ "$CheckBoxmovieyearfolder" == "on" ]]) || ([[ "$tvshowyearfolder" == "1" ]] && [[ "$CheckBoxtvshowyearfolder" != "on" ]]) || ([[ "$tvshowyearfolder" == "0" ]] && [[ "$CheckBoxtvshowyearfolder" == "on" ]]) || ([[ "$MakeFolder" == "1" ]] && [[ "$CheckBoxMakeFolder" != "on" ]]) || ([[ "$MakeFolder" == "0" ]] && [[ "$CheckBoxMakeFolder" == "on" ]]);
				then
					#echo "$EnableAddYear : $CheckBoxEnableAddYear" >>"$VR_VideoStation_Folder/VideoRenamer/log/index.cgi.log"
					#if [[ -e "$VR_VideoStation_Folder/debug" ]];
					#	then
					#		echo "$(date +"%F %T") : full scan reset" >>"$VR_VideoStation_Folder/VideoRenamer/log/index.cgi.log"
					#fi
					${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'UPDATE video_file SET renamed_path = NULL, is_renamed = false;'"
					#echo "OK"
			fi
			functiongetconf

	fi
	echo '
	</section>'

	# Section RESUME
	echo '
	<section id="resume" class="tabcontent">
		<ul>'
		if [ -e "$VR_APP_TMP_PATH/resume" ];
			then
				#RESUME="$(grep '' "$VR_APP_TMP_PATH/resume")"
				#cat "$VR_APP_TMP_PATH/resume"
				#nl -b n "$VR_APP_TMP_PATH/resume"
				while read line; do
					echo '<li>'$line'</li>'
				done <"$VR_APP_TMP_PATH/resume"
			else
				RESUME="App must at least run once to be resumed"
		fi
		echo '
		<li>'$RESUME'</li>
		</ul>
	</section>'

	# Section HELP
	echo '
	<section id="help" class="tabcontent">
		<form method=GET action="index.cgi#help">
			<p>
			<li>
				Movie file will be renamed like: <br />
				(Title) - (Year) - (Resolution) - (Resolution X)x(Resolution Y) - (Video codec)-(Audio codec)<br />
			</li>
			<li>
				TV Show file will be renamed like: <br />
				(Title) - (Season)(Episode) - (Episode Name) - (Year) - (Resolution) - (Resolution X)x(Resolution Y) - (Video codec)-(Audio codec)<br />
			</li>
			<li>
				First run may be long if DB has many video files
			</li>
			</p>
			<p>&nbsp;</p>
			<p> Last renamed files can be logged in the /video/VideoRenamer/log/ .</p>
			<p>
			<input id="id_GenerateLogsButton" type="submit" name="GenerateLogs" value="Generate Logs" />
			</p>
			<p>&nbsp;</p>
			<p> Cancel last rename</p>
			<p>
			<input id="id_CancelButton" type="submit" name="CancelRename" value="Cancel" />
			</p>'
			
			if [ -e "$VR_VideoStation_Folder/debug" ];
				then
					echo '
					<p>&nbsp;</p>
					<p> Debug mode</p>
					<p>
					<input id="id_DebugMode" type="submit" name="DebugMode" value="Debug" />
					</p>'
			fi
			echo '
		</form>'
		GenerateLogsConf=`echo "$QUERY_STRING" | sed -n 's/^.*GenerateLogs=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
		CancelLastRename=`echo "$QUERY_STRING" | sed -n 's/^.*CancelRename=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
		DebugMode=`echo "$QUERY_STRING" | sed -n 's/^.*DebugMode=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
		
		if [ "$GenerateLogsConf" == "Generate+Logs" ];
			then
				
				. ${APP_TARGET_PATH}/scripts/logextraction.sh
		fi
		if [ "$CancelLastRename" == "Cancel" ];
			then
				
				. ${APP_TARGET_PATH}/scripts/cancellastjob.sh
		fi
				if [ "$DebugMode" == "Debug" ];
			then
				
				. ${APP_TARGET_PATH}/scripts/debug.sh
		fi
		echo '
	</section>'

	# Section HISTORY
	echo '
	<section id="history" class="tabcontent">
		<h1>Package Changelog</h1>
		<p>'
		if [ -e "${APP_TARGET_PATH}/HISTORY" ];
			then
				while read line; do
					echo '<li>'$line'</li>'
				done <"${APP_TARGET_PATH}/HISTORY"
		fi
		echo '
		</p>
	</section>

</div>'
# check if app running
if [ -e "$VR_APP_TMP_PATH/START" ];
	then 
		echo '
		<tr><td><center><p style="color:red;">Application running.... no changes can be made</p></center></td></tr>
		<tr><td><center><p style="color:red;">please retry in a few minutes</p></center></td></tr>'
fi
echo '
</body>
</html>'
