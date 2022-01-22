#!/bin/bash
# videorenamer.sh


APP_TARGET_PATH="/var/packages/VideoRenamer/target"
. ${APP_TARGET_PATH}/scripts/var.sh &&

# debug or not selection
if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		exec 3>&1 4>&2
		trap 'exec 2>&4 1>&3' 0 1 2 3
		exec 1>"$VR_VideoStation_Folder/VideoRenamer/log/output.log" 2>&1
		# Everything below will go to the output file
fi

# conf checker
. ${APP_TARGET_PATH}/scripts/confchecker.sh
# DEBUG
if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		echo "$(date +"%F %T") : confchecker passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
fi
# call the conf file
. $ConfFilePath
# DEBUG
if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		echo "$(date +"%F %T") : conffile called" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
fi

# max log size
if [ -z "$LogMaxSize" ];
	then
		LogMaxSize="5"
fi
LogMaxSize="$(($LogMaxSize * 1000000))" # default value 1000000
# DEBUG
if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		echo "$(date +"%F %T") : LogMaxSize set" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
fi

# check if script already running
if [ -e "$VR_APP_TMP_PATH/START" ];
	then
		# DEBUG
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				echo "$(date +"%F %T") : ERROR : script already running" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
		fi
		exit
fi

# check if error log already exist
if [ -e "${VR_APP_LOG_PATH}/$ErrorLogName.log" ];
	then 
		rm -f "${VR_APP_LOG_PATH}/$ErrorLogName.log"
		# DEBUG
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				echo "$(date +"%F %T") : error log removed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
		fi
fi


# set app start time
#echo "VideoRenamer started $(date +"%F") at $(date +"%H:%M")" >>"${VR_APP_TMP_PATH}/lastruntime.log"


Function_Reset_Var () {
CheckLogDate="0"
IsItAMovie="0"
IsItATVShow="0"
CorrectVideoNameLogHasDate="0"
NotCorrectVideoNameLogHasDate="0"
VideoNbr="0"

if [ -e "$VR_APP_TMP_PATH/movienbr" ];
	then
		rm "$VR_APP_TMP_PATH/movienbr"
fi
if [ -e "$VR_APP_TMP_PATH/tvshownbr" ];
	then
		rm "$VR_APP_TMP_PATH/tvshownbr"
fi

# DEBUG
if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		echo "$(date +"%F %T") : Function_Reset_Var : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
fi
}

Function_Language_Detection () {
	# we are looking for the some words which are very often present in French "Un " "Une " "Le " "La "... Les " in the SUMMARY because there are usually present in French langage
	if [[ `echo $SUMMARY | grep -c "Un \| un \|Une \| une \|Les \| les \|Le \| le \|La \| la \|Les \| les \| l'\|L'\| est \| et \| sont \| deux \|Deux \|Trois \| trois \|Quatre \| quatre \|Cinq \| cinq \|Sept \| sept \|Huit \| huit \|Neuf \| neuf \|Dix \| dix \| dans \| pour \| son \| des \| du \| beaucoup \| histoire "` -gt 0 ]];
		then
			#AuthorizedSpecialCharacters="$(echo $AuthorizedSpecialCharacters |sed 's/&/Et/g' )"
			ChosenLang="Fr"
			SeasonTrad="Saison"
	fi
	# we are looking for the some words which are very often present in English 
	if [[ `echo $SUMMARY | grep -c "One \| one \|She \| she \|They \| they \|It \| it \|The \| the \| and \|Two \| two \|Three \| three \| for \|Four \| four \|Five \| five \|Seven \| seven \|Eight \| eight \|Nine \| nine \|Ten \| ten \| that \|That \| ability \| able \| about \| above \| according \| account \| across \| activity \| actually \| add \| address "` -gt 0 ]];
		then
			#AuthorizedSpecialCharacters="$(echo $AuthorizedSpecialCharacters |sed 's/&/And/g' )"
			ChosenLang="Us"
			SeasonTrad="Season"
	fi
	# we are looking for the some words which are very often present in German 
	if [[ `echo $SUMMARY | grep -c "Eins \| eins \|Sie \| sie \|Das \| das \|Zwei \| zwei \|Drei \| drei \| und \| für \|Vier \| vier \|Fünf \| fünf \|Sechs \| sechs \|Sieben \| sieben \|Acht \| acht \|Neun \| neun \|Zehn \| zehn \| geschichte \|Geschichte \| verhandlungen \| jedenfalls \| trotz \| darunter \| spieler \| fordern \| beispiel \| meinungen \| wenigen \| publikum \| sowohl \| meinte \| mögen \| lösung \| boden \| hinaus \| verletzen \| weltweit \| produktion \| sohn "` -gt 0 ]];
		then
			#AuthorizedSpecialCharacters="$(echo $AuthorizedSpecialCharacters |sed 's/&/Und/g' )"
			ChosenLang="De"
			SeasonTrad="Staffel"
	fi
	if [[ -z $SeasonTrad ]];
		then
			SeasonTrad="Season"
	fi
	if [[ -z $ChosenLang ]];
		then
			ChosenLang="Us"
	fi
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_Language_Detection : $ChosenLang selected" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Function_Get_Video_Info () {
	DB_IS_RENAMED="$(echo $ENTRY|cut -f1 -s -d"|")"
	DB_RENAMED_PATH="$(echo "$ENTRY"|cut -f2 -s -d"|")"
	DB_OLD_PATH="$(echo "$ENTRY"|cut -f3 -s -d"|")"
	DB_DAR_RESOLUTION_X="$(echo $ENTRY|cut -f4 -s -d"|")"
	DB_LAST_RENAMED_DATE="$(echo $ENTRY|cut -f5 -s -d"|")"
	DB_RESOLUTION_NAMING="$(echo $ENTRY|cut -f6 -s -d"|")"
	DB_NEW_FILENAME="$(echo "$ENTRY"|cut -f7 -s -d"|")"
	DB_OLD_FILENAME="$(echo "$ENTRY"|cut -f8 -s -d"|")"
	VR_OLD_PATH="$(echo "$ENTRY"|cut -f9 -s -d"|")"
	VR_NEW_PATH="$(echo "$ENTRY"|cut -f10 -s -d"|")"
	VR_NEW_PATH_CHECK="$VR_NEW_PATH"
	DB_ID="$(echo $ENTRY|cut -f11 -s -d"|")"
	TITRE="$(echo $ENTRY|cut -f12 -s -d"|")"
	CHEMIN="$(echo "$ENTRY"|cut -f13 -s -d"|")"
	YEAR="$(echo $ENTRY|cut -f14 -s -d"|")"
	RESOLUTIONX="$(echo $ENTRY|cut -f15 -s -d"|")"
	RESOLUTIONY="$(echo $ENTRY|cut -f16 -s -d"|")"
	VIDEO_CODEC="$(echo $ENTRY|cut -f17 -s -d"|")"
	AUDIO_CODEC="$(echo $ENTRY|cut -f18 -s -d"|")"
	
	SEASON="$(echo $ENTRY|cut -f19 -s -d"|")"
	EPISODE="$(echo $ENTRY|cut -f20 -s -d"|")"
	EPISODE_NAME="$(echo $ENTRY|cut -f21 -s -d"|")"
	SERIE_ORIGINALLY_AVAILABLE="$(echo $ENTRY|cut -f22 -s -d"|")"
	SERIE_ORIGINAL_DATE=$(echo $SERIE_ORIGINALLY_AVAILABLE|cut -c1-4)
	# SUMMARY recuperer dans la partie lié au film ou tvshow car pas au meme emplacement
	#SUMMARY="$(echo $ENTRY|cut -f23 -s -d"|")"
	
	###########################################################################################
	#    get folder and file name   #
	###########################################################################################
	DOSSIER="$(dirname "$CHEMIN")"
	OLD_FILENAME="$(basename "$CHEMIN")"
	EXTENSION="${CHEMIN##*.}"
	OLD_NAME="${OLD_FILENAME%.*}"
	# on check si l année existe
	if [[ $YEAR == "0" ]] || [[ -z $YEAR ]];
		then
			YEAR="0000"
	fi
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_Get_Video_Info : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : DB_IS_RENAMED : $DB_IS_RENAMED" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : DB_RENAMED_PATH : $DB_RENAMED_PATH" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : DB_OLD_PATH : $DB_OLD_PATH" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : DB_DAR_RESOLUTION_X : $DB_DAR_RESOLUTION_X" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : DB_LAST_RENAMED_DATE : $DB_LAST_RENAMED_DATE" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : DB_RESOLUTION_NAMING : $DB_RESOLUTION_NAMING" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : DB_NEW_FILENAME : $DB_NEW_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : DB_OLD_FILENAME : $DB_OLD_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : VR_OLD_PATH : $VR_OLD_PATH" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : VR_NEW_PATH : $VR_NEW_PATH" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : DB_ID : $DB_ID" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : TITRE : $TITRE" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : CHEMIN : $CHEMIN" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : YEAR : $YEAR" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : RESOLUTIONX : $RESOLUTIONX" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : RESOLUTIONY : $RESOLUTIONY" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : VIDEO_CODEC : $VIDEO_CODEC" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : AUDIO_CODEC : $AUDIO_CODEC" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : SUMMARY : $SUMMARY" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : SEASON : $SEASON" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : EPISODE : $EPISODE" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : EPISODE_NAME : $EPISODE_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : SERIE_ORIGINALLY_AVAILABLE : $SERIE_ORIGINALLY_AVAILABLE" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : SERIE_ORIGINAL_DATE : $SERIE_ORIGINAL_DATE" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : DOSSIER : $DOSSIER" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : OLD_FILENAME : $OLD_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : EXTENSION : $EXTENSION" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : OLD_NAME : $OLD_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : MakeFolder : $MakeFolder" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : ChosenLang : $ChosenLang" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : SeasonTrad : $SeasonTrad" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : movieyearfolder is set to: $movieyearfolder" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Function_Get_Video_Info : delemptyfolder is set to: $delemptyfolder" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			
			
	fi
}

Function_Filename_Cleaning () {
	Function_Language_Detection
	#Suppression des caracteres speciaux
	if [ "$DeleteNotAdvisedSpecialCharacters" == "1" ];
		then 
			NotAdvisedSpecialCharacters="$(echo $NewFilenameLayout |sed 's/,//g' |sed 's/:/ -/g' |sed -e 's/\*/-/g' |sed 's/"//g' |sed 's/;//g' |sed -e 's/?//g' |sed -e 's/\!//g' |sed 's/\//-/g' |sed -e 's/\xc2\xa0/ /g' |sed -e 's/  / /g')"
			#NotAdvisedSpecialCharacters="$(echo $NewFilenameLayout |sed 's/,//g' |sed 's/:/-/g' |sed 's/;//g' |sed -e 's/?//g' |sed -e 's/!//g' |sed 's/\//-/g' |sed -e 's/\xc2\xa0/ /g' )"

		else
			NotAdvisedSpecialCharacters="$NewFilenameLayout"
	fi
	#Suppression des lettres speciales
	if [ "$DeleteSpecialLetters" == "1" ];
		then 
			SpecialLetters="$(echo $NotAdvisedSpecialCharacters |sed 's/à/a/g' |sed 's/â/a/g' |sed 's/ç/c/g' |sed 's/é/e/g' |sed 's/è/e/g' |sed 's/ê/e/g' |sed 's/ë/e/g' |sed 's/î/i/g' |sed 's/ï/i/g' |sed 's/ô/o/g' |sed 's/ö/o/g' |sed 's/œ/oe/g' |sed 's/Œ/oe/g' |sed 's/ù/u/g' |sed 's/ü/u/g' |sed 's/Â/A/g' |sed 's/Ç/C/g' |sed 's/É/E/g' |sed 's/È/E/g' |sed 's/Ê/E/g' |sed 's/Ë/E/g' |sed 's/Î/I/g' |sed 's/Ï/I/g' |sed 's/Ô/O/g' |sed 's/Ö/O/g' |sed 's/Ù/U/g' |sed 's/Ü/U/g' |sed -e 's/À/A/g' )"
		else
			SpecialLetters="$NotAdvisedSpecialCharacters"
	fi		
	#Suppression des caracteres speciaux authorisé
	if [ "$DeleteAuthorizedSpecialCharacters" == "1" ];
		then 
			AuthorizedSpecialCharacters="$(echo $SpecialLetters |sed -e 's/\$//g' |sed "s/'/ /g" |sed "s/,/ /g" |sed -e 's/·/ /g' |sed -e 's/\’/./g' |sed -e 's/#//g' |sed -e 's/ß/ss/g' )" 
			
			if [[ "$ChosenLang" -eq "Fr" ]];
				then
					AuthorizedSpecialCharacters="$(echo $AuthorizedSpecialCharacters |sed 's/&/Et/g' )"
			fi
			if [[ "$ChosenLang" -eq "Us" ]];
				then
					AuthorizedSpecialCharacters="$(echo $AuthorizedSpecialCharacters |sed 's/&/And/g' )"
			fi
			if [[ "$ChosenLang" -eq "De" ]];
				then
					AuthorizedSpecialCharacters="$(echo $AuthorizedSpecialCharacters |sed 's/&/Und/g' )"
			fi
			#Function_Language_Detection
		else
			AuthorizedSpecialCharacters="$SpecialLetters"
	fi
	#Suppression des espaces
	if [ "$DeleteWhiteSpace" == "1" ];
		then 
			WhiteSpace="$(echo $AuthorizedSpecialCharacters |sed -e 's/ /./g' )"
			#on remplace les ".." par un seul "."
			AuthorizedSpecialCharacters="$(echo "$AuthorizedSpecialCharacters" |sed 's/.././g' )"
		else
			WhiteSpace="$AuthorizedSpecialCharacters"
	fi
	#deleting non printable character
	NEW_NAME_B="$(tr -dc '[[:print:]]' <<< "$WhiteSpace")"
	#on remplace les ".." et a space, tab, carriage return, newline, vertical tab, or form feed par " "
	NEW_NAME="$(echo "$NEW_NAME_B" |sed -e "s/[[:space:]]\+/ /g" )"
	NEW_NAME="${WhiteSpace}"
	NEW_NAME="$(echo "$NEW_NAME" |sed 's/  / /g' )"
	NEW_PATH="$DOSSIER/$NEW_NAME"
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_Filename_Cleaning : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Function_File_Exist_Check () {
	if [ -e "$NEW_PATH.$EXTENSION" ]; 
		then
			#echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 2>&1 >/dev/null
			#echo "fichier $NEW_PATH exist deja" 2>&1 >/dev/null
			NEW_PATH="${NEW_PATH} - $DB_ID"
			NEW_NAME="${NEW_NAME} - $DB_ID"
			NEW_NAME="$(echo "$NEW_NAME" |sed 's/  / /g' )"
			if [ "$DeleteWhiteSpace" = "1" ];
				then 
					NEW_NAME="$(echo $NEW_NAME |sed -e 's/ /./g' )"
					NEW_PATH="$DOSSIER/$NEW_NAME"
			fi
			# DEBUG
			if [ -e "$VR_VideoStation_Folder/debug" ];
				then
					echo "$(date +"%F %T") : Function_File_Exist_Check : file already exist - adding ID: $DB_ID" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			fi
	fi
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_File_Exist_Check : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Function_Check_Log_Path () {
	VideoLogName="VideoNotRenamed"
	if [ "$CorrectVideoName" == "0" ];
		then
			VideoLogName="VideoRenamed"
	fi
	Function_Check_File_Size &&
	echo 2>&1 >/dev/null
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_Check_Log_Path : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Function_Check_File_Size () {
	for file in "$VR_APP_LOG_PATH/";
		do
			if [[ "$(stat -c%s "$file")" -ge "$LogMaxSize" ]];
				then
					mv "${VR_APP_LOG_PATH}/$file" "${VR_APP_LOG_PATH}/$file.bkp" 
			fi
		done
	#rename old logs if they exist
	if [ -e "${VR_APP_LOG_PATH}/$VideoLogName.log" ] && [[ "$(stat -c%s "${VR_APP_LOG_PATH}/$VideoLogName.log")" -ge "$LogMaxSize" ]]; # logs backed up
		then
			mv "${VR_APP_LOG_PATH}/$VideoLogName.log" "${VR_APP_LOG_PATH}/$VideoLogName.bkp" 
	fi
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_Check_File_Size : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Function_Check_Log_Date () {
	Function_Check_Log_Path
	if [ "$CheckLogDate" == "0" ];
		then
			if [ "$IsItAMovie" == "1" ];
				then TypeOfVideo="Movie "
			fi
			if [ "$IsItATVShow" == "1" ];
				then TypeOfVideo="TVShow"
			fi
			echo "**********************************" >>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
			echo "*          $TypeOfVideo                *">>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
			echo "**********************************">>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
	fi
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_Check_Log_Date : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Function_Check_Both_Log_Have_Date () {
	if ([ $CorrectVideoName == 1 ] && [ $CorrectVideoNameLogHasDate == 1 ]) || ([ $CorrectVideoName == 0 ] && [ $NotCorrectVideoNameLogHasDate == 1 ]);
		then
			CheckLogDate="1"
		else
			CheckLogDate="0"
	fi
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_Check_Both_Log_Have_Date : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}


Function_Check_And_Rename () {


	# check vr_old_path
	if [[ -z "$VR_OLD_PATH" ]];
		then
			#pour eviter les quotes dans la variable, il faut la doubler
			VR_OLD_PATH=$(echo $VR_OLD_PATH |sed "s/'/''/g" )
			#ExecSqlCommand "UPDATE video_file SET vr_old_path = (SELECT LEFT(path, (select length(path) - position('/' in reverse(path))) )) where vr_old_path IS NULL AND id = '$DB_ID';"
			VR_OLD_PATH="$(ExecSqlCommand "SELECT LEFT(path, (select length(path) - position('/' in reverse(path)) )) FROM video_file where id = '$DB_ID';")"
			ExecSqlCommand "UPDATE video_file SET vr_old_path = '$VR_OLD_PATH' where vr_old_path IS NULL AND id = '$DB_ID';"
	fi

	#test du fichier pour voir si il est corrompu
	if [ "$RESOLUTIONX" -eq "0" ] && [ "$RESOLUTIONY" -eq "0" ];
		then
			CorrectVideoName="0"
			Function_Check_Both_Log_Have_Date
			Function_Check_Log_Date
			echo "************** CORRUPTED FILE **************" >>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
			echo "Chemin :" $DOSSIER >>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
			echo "Corrupted file: "$OLD_NAME.$EXTENSION >>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
			echo "------" >>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
			NotCorrectVideoNameLogHasDate="1"
			# DEBUG
			if [ -e "$VR_VideoStation_Folder/debug" ];
				then
					echo "$(date +"%F %T") : Function_Check_And_Rename : file corrupted" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			fi
		else
			###########################################################################################
			#                      On verifie si le chemin doit etre modifie                          #
			###########################################################################################
			if [[ "$MakeFolder" -eq "1" ]];
				then
					LIB_PATH="$(echo "$DOSSIER" | cut -d"/" -f 1-4)"
					if [[ "$IsItAMovie" -eq "1" ]]; 
						then #partie traitement des films
							MovieFolder="$TITRE ($YEAR)"
							# on nettoie le nom du film
							MovieFolder="$(echo $MovieFolder |sed 's/,//g' |sed 's/:/ -/g' |sed 's/"//g' |sed -e 's/\*/-/g' |sed 's/;//g' |sed -e 's/?//g' |sed -e 's/\!//g' |sed 's/\//-/g' |sed -e 's/\xc2\xa0/ /g' |sed -e 's/  / /g')"
							#if year folder activated add year folder before movie folder
							if [[ $movieyearfolder == "1" ]];
								then
									MovieFolder="${YEAR::-1}x/$MovieFolder"
									NEW_PATH="$LIB_PATH/$MovieFolder/$NEW_NAME"
								else
									# on check si le film est dans le dossier library ou dans un autre dossier
									if [[ -z "${DOSSIER##$LIB_PATH}" ]];
										then
											NEW_PATH="$LIB_PATH/$MovieFolder/$NEW_NAME"
										else
											NEW_PATH="$(dirname "$DOSSIER")/$MovieFolder/$NEW_NAME"
									fi
							fi
							
						else #partie traitement des series
							TVShowFolder="$TITRE ($YEAR)"
							#fi
							# on nettoie le nom de la serie
							TVShowFolder="$(echo $TVShowFolder |sed 's/,//g' |sed 's/:/ -/g' |sed 's/"//g' |sed -e 's/\*/-/g' |sed 's/;//g' |sed -e 's/?//g' |sed -e 's/\!//g' |sed 's/\//-/g' |sed -e 's/\xc2\xa0/ /g' |sed -e 's/  / /g')"
							SeasonFolder="$SeasonTrad $SEASON"
							if [[ -z "${DOSSIER##$LIB_PATH}" ]];
								then
									if [[ $tvshowyearfolder == "1" ]];
										then
											NEW_PATH="$LIB_PATH/${YEAR::-1}x/$TVShowFolder/$SeasonFolder/$NEW_NAME"
										else
											NEW_PATH="$LIB_PATH/$TVShowFolder/$SeasonFolder/$NEW_NAME"
									fi
									#echo "1" >> /volume1/Links/Dev/debug.txt
								else
									if [[ "$(grep -o "/" <<< ${DOSSIER##$(echo "$LIB_PATH" | cut -d"/" -f 1-4)} | wc -l)" -ge "2" ]];
										then
											NEW_PATH="$(echo $(dirname "$DOSSIER") | sed 's%/[^/]*$%%')/$TVShowFolder/$SeasonFolder/$NEW_NAME"
											#echo "2" >> /volume1/Links/Dev/debug.txt
										else
											NEW_PATH="$(dirname "$DOSSIER")/$TVShowFolder/$SeasonFolder/$NEW_NAME"
											#echo "3" >> /volume1/Links/Dev/debug.txt
									fi
							fi
					fi
					if [[ -e "$VR_VideoStation_Folder/debug" ]];
						then
							echo "$(date +"%F %T") : Function_Check_And_Rename : folder module - TVShowFolder : $TVShowFolder" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							echo "$(date +"%F %T") : Function_Check_And_Rename : folder module - SeasonFolder : $SeasonFolder" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							echo "$(date +"%F %T") : Function_Check_And_Rename : folder module - DOSSIER : $DOSSIER" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							echo "$(date +"%F %T") : Function_Check_And_Rename : folder module - NEW_NAME : $NEW_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							echo "$(date +"%F %T") : Function_Check_And_Rename : folder module - LIB_PATH : $LIB_PATH" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
					fi
					if [[ ! -e "$NEW_PATH" ]];
						then
							mkdir -p "$(dirname "$NEW_PATH")"
							errorfold=$?
							if [[ "$errorfold" -eq "0" ]] && [[ -e "$VR_VideoStation_Folder/debug" ]];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : folder module - NEW_PATH : $NEW_PATH" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
									echo "$(date +"%F %T") : Function_Check_And_Rename : folder module - new folder created" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								elif [[ -e "$VR_VideoStation_Folder/debug" ]];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : folder module - NEW_PATH : $NEW_PATH" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : folder module - folder creation failed with error code: $errorfold" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
					fi
			fi
			VR_NEW_PATH="$(dirname "$NEW_PATH")"
			if [[ -e "$VR_VideoStation_Folder/debug" ]];
				then
					echo "$(date +"%F %T") : Function_Check_And_Rename : folder module - VR_NEW_PATH : $VR_NEW_PATH" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			fi
			###########################################################################################
			#                      On verifie si le nom doit etre modifie                             #
			###########################################################################################
			if [ -e "$VR_VideoStation_Folder/debug" ];
				then
					echo "$(date +"%F %T") : Function_Check_And_Rename : filename is OK checking DB entries" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
					echo "$(date +"%F %T") : Function_Check_And_Rename : CHEMIN : $CHEMIN" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
					echo "$(date +"%F %T") : Function_Check_And_Rename : NEW_PATH.EXTENSION : $NEW_PATH.$EXTENSION" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
					echo "$(date +"%F %T") : Function_Check_And_Rename : NEW_PATH - DB_ID.EXTENSION : ${NEW_PATH} - $DB_ID.$EXTENSION" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
					echo "$(date +"%F %T") : Function_Check_And_Rename : OLD_NAME : $OLD_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
					echo "$(date +"%F %T") : Function_Check_And_Rename : NEW_NAME : $NEW_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
					echo "$(date +"%F %T") : Function_Check_And_Rename : VR_OLD_PATH : $VR_OLD_PATH" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
					echo "$(date +"%F %T") : Function_Check_And_Rename : VR_NEW_PATH : $VR_NEW_PATH" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
					#echo "$(date +"%F %T") : Function_Check_And_Rename : NEW_PATH_xx_DB_ID : ${NEW_PATH}*$DB_ID" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			fi
			if [ "$CHEMIN" == "$NEW_PATH.$EXTENSION" ] || ([ "$CHEMIN" == "${NEW_PATH} - $DB_ID.$EXTENSION" ] && [ -e "$NEW_PATH.$EXTENSION" ]) || ([ "$OLD_NAME" == "$NEW_NAME" ] && [ "$VR_OLD_PATH" == "$VR_NEW_PATH" ]) || ([ "$OLD_NAME" == "${NEW_PATH}*$DB_ID" ] && [ -e "$NEW_PATH.$EXTENSION" ]);
				then
					CorrectVideoName="1"
					if [ -z "$VR_NEW_PATH_CHECK" ];
						then
							#pour eviter les quotes dans la variable, il faut la doubler
							VR_NEW_PATH_DQ=$(echo $VR_NEW_PATH |sed "s/'/''/g" )
							${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET vr_new_path = '$VR_NEW_PATH_DQ' WHERE id= '$DB_ID';"
							# DEBUG
							if [ -e "$VR_VideoStation_Folder/debug" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : updating vr_new_path" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
					fi
					if [ -z "$DB_NEW_FILENAME" ];
						then
							#pour eviter les quotes dans la variable, il faut la doubler
							NEW_FILENAME=$(echo $OLD_NAME.$EXTENSION |sed "s/'/''/g" )
							${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET new_filename = '$NEW_FILENAME' WHERE id= '$DB_ID';"
							# DEBUG
							if [ -e "$VR_VideoStation_Folder/debug" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : updating new_filename" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
					fi
					if [ -z "$DB_OLD_FILENAME" ];
						then
							#pour eviter les quotes dans la variable, il faut la doubler
							OLD_FILENAME=$(echo $OLD_NAME.$EXTENSION |sed "s/'/''/g" )
							${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET old_filename = '$OLD_FILENAME' WHERE id= '$DB_ID';"
							# DEBUG
							if [ -e "$VR_VideoStation_Folder/debug" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : updating old_filename" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
					fi
					if [ -z "$DB_RENAMED_PATH" ];
						then
							#pour eviter les quotes dans la variable, il faut la doubler
							DB_RENAMED_PATH=$(echo $DOSSIER/$OLD_NAME.$EXTENSION |sed "s/'/''/g" )
							${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET renamed_path = '$DB_RENAMED_PATH' WHERE id= '$DB_ID';"
							# DEBUG
							if [ -e "$VR_VideoStation_Folder/debug" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : updating renamed_path" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
					fi
					if [ -z "$DB_DAR_RESOLUTION_X" ];
						then
							${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET dar_resolution_x = '$NEW_RESOLUTIONX' WHERE id= '$DB_ID';"
							# DEBUG
							if [ -e "$VR_VideoStation_Folder/debug" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : updating dar_resolution_x" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
					fi
					if [ -z "$DB_RESOLUTION_NAMING" ];
						then
							${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET resolution_naming = '$AddResolutionNaming' WHERE id= '$DB_ID';"
							# DEBUG
							if [ -e "$VR_VideoStation_Folder/debug" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : updating resolution_naming" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
					fi
					if [ "$DB_IS_RENAMED" = "f" ];
						then
							${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET is_renamed = true WHERE id= '$DB_ID';"
							# DEBUG
							if [ -e "$VR_VideoStation_Folder/debug" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : updating is_renamed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
					fi
					if [ -z "$EPISODE_NAME" ];
						then
							${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET title_checker = title FROM movie WHERE movie.mapper_id=video_file.mapper_id and video_file.id= '$DB_ID';"
							# DEBUG
							if [ -e "$VR_VideoStation_Folder/debug" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : updating title_checker from title" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
						else
							#${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET title_checker = tag_line FROM tvshow_episode,video_file WHERE tvshow_episode.mapper_id=video_file.mapper_id and video_file.id= '$DB_ID';"
							${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET title_checker = tag_line FROM tvshow_episode WHERE tvshow_episode.mapper_id=video_file.mapper_id and video_file.id= '$DB_ID';"
							# DEBUG
							if [ -e "$VR_VideoStation_Folder/debug" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : updating title_checker from tag_line" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
					fi
					CorrectVideoNameLogHasDate="1"
				else
					# DEBUG
					if [ -e "$VR_VideoStation_Folder/debug" ];
						then
							if [ -z "$NEW_PATHWithoutQuotes" ] && [ -z "$DB_OLD_PATH" ] && [ -z "$NEW_RESOLUTIONX" ] && [ -z "$AddResolutionNaming" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : var OK" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								else
									echo "$(date +"%F %T") : Function_Check_And_Rename : ERROR : no VAR declared" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
					fi
					# on verifie si le fichier exist deja
					Function_File_Exist_Check
					# on renomme le vsmeta si il exist
					if [ -e "${DOSSIER}/$OLD_NAME.$EXTENSION.vsmeta" ];
						then
							mv "${DOSSIER}/$OLD_NAME.$EXTENSION.vsmeta" "$NEW_PATH.$EXTENSION.vsmeta"
							# DEBUG
							if [ -e "$VR_VideoStation_Folder/debug" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : vsmeta moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
					fi
					# on renomme le ass si il exist
					ASS_Files=$(ls "$DOSSIER/$OLD_NAME"*.ass 2> /dev/null | wc -l)
					if [ "$ASS_Files" != "0" ];
						then
							for subtitle in "${DOSSIER}/$OLD_NAME"*.ass; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$OLD_NAME}"
								ifilename="$(echo $ifilename |sed 's/- -/-/g' )"
								# check if ifilename is empty to avoid blanks at end of file
								if [[ -z $ifilename ]];
									then
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME}.ass"
									else
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME} ${ifilename%.*}.ass"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : ASS_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : ASS_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : ASS_Files : DOSSIER/OLD_NAME : $DOSSIER/$OLD_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : ASS_Files : NEW_PATH/NEW_NAME : $NEW_PATH/$NEW_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : ASS_Files : ass moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								fi
							done
							
					fi
					# on renomme le sami si il exist
					SAMI_Files=$(ls "$DOSSIER/$OLD_NAME"*.sami 2> /dev/null | wc -l)
					if [ "$SAMI_Files" != "0" ];
						then
							for subtitle in "${DOSSIER}/$OLD_NAME"*.sami; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$OLD_NAME}"
								ifilename="$(echo $ifilename |sed 's/- -/-/g' )"
								# check if ifilename is empty to avoid blanks at end of file
								if [[ -z $ifilename ]];
									then
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME}.sami"
									else
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME} ${ifilename%.*}.sami"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SAMI_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SAMI_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SAMI_Files : DOSSIER/OLD_NAME : $DOSSIER/$OLD_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SAMI_Files : NEW_PATH/NEW_NAME : $NEW_PATH/$NEW_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SAMI_Files : sami moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								fi
							done
					fi
					# on renomme le smi si il exist
					SMI_Files=$(ls "$DOSSIER/$OLD_NAME"*.smi 2> /dev/null | wc -l)
					if [ "$SMI_Files" != "0" ];
						then
							for subtitle in "${DOSSIER}/$OLD_NAME"*.smi; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$OLD_NAME}"
								ifilename="$(echo $ifilename |sed 's/- -/-/g' )"
								# check if ifilename is empty to avoid blanks at end of file
								if [[ -z $ifilename ]];
									then
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME}.smi"
									else
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME} ${ifilename%.*}.smi"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SMI_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SMI_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SMI_Files : DOSSIER/OLD_NAME : $DOSSIER/$OLD_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SMI_Files : NEW_PATH/NEW_NAME : $NEW_PATH/$NEW_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SMI_Files : smi moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								fi
							done
					fi
					# on renomme le srt si il exist
					SRT_Files=$(ls "$DOSSIER/$OLD_NAME"*.srt 2> /dev/null | wc -l)
					if [ "$SRT_Files" != "0" ];
						then
							for subtitle in "${DOSSIER}/$OLD_NAME"*.srt; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$OLD_NAME}"
								ifilename="$(echo $ifilename |sed 's/- -/-/g' )"
								# check if ifilename is empty to avoid blanks at end of file
								if [[ -z $ifilename ]];
									then
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME}.srt"
									else
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME} ${ifilename%.*}.srt"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SRT_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SRT_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SRT_Files : DOSSIER/OLD_NAME : $DOSSIER/$OLD_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SRT_Files : NEW_PATH/NEW_NAME : $NEW_PATH/$NEW_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SRT_Files : srt moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								fi
							done
					fi
					# on renomme le vtt si il exist
					if [ "$VTT_Files" != "0" ];
						then
							for subtitle in "${DOSSIER}/$OLD_NAME"*.vtt; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$OLD_NAME}"
								ifilename="$(echo $ifilename |sed 's/- -/-/g' )"
								# check if ifilename is empty to avoid blanks at end of file
								if [[ -z $ifilename ]];
									then
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME}.vtt"
									else
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME} ${ifilename%.*}.vtt"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : VTT_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : VTT_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : VTT_Files : DOSSIER/OLD_NAME : $DOSSIER/$OLD_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : VTT_Files : NEW_PATH/NEW_NAME : $NEW_PATH/$NEW_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : VTT_Files : vtt moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								fi
							done
					fi
					# on renomme le ttml si il exist
					TTML_Files=$(ls "$DOSSIER/$OLD_NAME"*.ttml 2> /dev/null | wc -l)
					if [ "$TTML_Files" != "0" ];
						then
							for subtitle in "${DOSSIER}/$OLD_NAME"*.ttml; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$OLD_NAME}"
								ifilename="$(echo $ifilename |sed 's/- -/-/g' )"
								# check if ifilename is empty to avoid blanks at end of file
								if [[ -z $ifilename ]];
									then
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME}.ttml"
									else
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME} ${ifilename%.*}.ttml"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : TTML_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : TTML_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : TTML_Files : DOSSIER/OLD_NAME : $DOSSIER/$OLD_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : TTML_Files : NEW_PATH/NEW_NAME : $NEW_PATH/$NEW_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : TTML_Files : ttml moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								fi
							done
					fi
					# on renomme le ssa si il exist
					SSA_Files=$(ls "$DOSSIER/$OLD_NAME"*.ssa 2> /dev/null | wc -l)
					if [ "$SSA_Files" != "0" ];
						then
							for subtitle in "${DOSSIER}/$OLD_NAME"*.ssa; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$OLD_NAME}"
								ifilename="$(echo $ifilename |sed 's/- -/-/g' )"
								# check if ifilename is empty to avoid blanks at end of file
								if [[ -z $ifilename ]];
									then
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME}.ssa"
									else
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME} ${ifilename%.*}.ssa"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SSA_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SSA_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SSA_Files : DOSSIER/OLD_NAME : $DOSSIER/$OLD_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SSA_Files : NEW_PATH/NEW_NAME : $NEW_PATH/$NEW_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SSA_Files : ssa moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								fi
							done
					fi
					# on renomme le idx si il exist
					IDX_Files=$(ls "$DOSSIER/$OLD_NAME"*.idx 2> /dev/null | wc -l)
					if [ "$IDX_Files" != "0" ];
						then
							for subtitle in "${DOSSIER}/$OLD_NAME"*.idx; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$OLD_NAME}"
								ifilename="$(echo $ifilename |sed 's/- -/-/g' )"
								# check if ifilename is empty to avoid blanks at end of file
								if [[ -z $ifilename ]];
									then
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME}.idx"
									else
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME} ${ifilename%.*}.idx"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : IDX_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : IDX_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : IDX_Files : DOSSIER/OLD_NAME : $DOSSIER/$OLD_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : IDX_Files : NEW_PATH/NEW_NAME : $NEW_PATH/$NEW_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : IDX_Files : idx moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								fi
							done
							
					fi
					# on renomme le sub si il exist
					SUB_Files=$(ls "$DOSSIER/$OLD_NAME"*.sub 2> /dev/null | wc -l)
					if [ "$SUB_Files" != "0" ];
						then
							for subtitle in "${DOSSIER}/$OLD_NAME"*.sub; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$OLD_NAME}"
								ifilename="$(echo $ifilename |sed 's/- -/-/g' )"
								# check if ifilename is empty to avoid blanks at end of file
								if [[ -z $ifilename ]];
									then
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME}.sub"
									else
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME} ${ifilename%.*}.sub"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SUB_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SUB_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SUB_Files : DOSSIER/OLD_NAME : $DOSSIER/$OLD_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SUB_Files : NEW_PATH/NEW_NAME : $NEW_PATH/$NEW_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SUB_Files : sub moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								fi
							done
							
					fi
					# on renomme le nfo si il exist
					NFO_Files=$(ls "$DOSSIER/$OLD_NAME"*.nfo 2> /dev/null | wc -l)
					if [ "$NFO_Files" != "0" ];
						then
							for subtitle in "${DOSSIER}/$OLD_NAME"*.nfo; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$OLD_NAME}"
								ifilename="$(echo $ifilename |sed 's/- -/-/g' )"
								# check if ifilename is empty to avoid blanks at end of file
								if [[ -z $ifilename ]];
									then
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME}.nfo"
									else
										mv "$subtitle" "$(dirname "$NEW_PATH")/${NEW_NAME} ${ifilename%.*}.nfo"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : NFO_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : NFO_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : NFO_Files : DOSSIER/OLD_NAME : $DOSSIER/$OLD_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : NFO_Files : NEW_PATH/NEW_NAME : $NEW_PATH/$NEW_NAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : NFO_Files : nfo moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								fi
							done
							
					fi
					# On renomme le fichier
					mv "$CHEMIN" "$NEW_PATH.$EXTENSION"
					MVErrorCode=$(echo $?)
					if [ "$MVErrorCode" -eq "0" ]; 
						then
							# DEBUG
							if [ -e "$VR_VideoStation_Folder/debug" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : video file moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							fi
							synoindex -d "$CHEMIN"
							#pour eviter les quotes dans la variable, il faut la doubler
							NEW_PATHWithoutQuotes=$(echo $NEW_PATH.$EXTENSION |sed "s/'/''/g" )
							DB_OLD_PATH=$(echo $DOSSIER/$OLD_NAME.$EXTENSION |sed "s/'/''/g" )
							NEW_FILENAME=$(echo $NEW_NAME.$EXTENSION |sed "s/'/''/g" )
							OLD_FILENAME=$(echo $OLD_NAME.$EXTENSION |sed "s/'/''/g" )
							VR_NEW_PATH_DQ=$(echo $VR_NEW_PATH |sed "s/'/''/g" )
							# on met a jour la DB
							if [ -z "$EPISODE_NAME" ];
								then
									${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET path = '$NEW_PATHWithoutQuotes',old_path = '$DB_OLD_PATH',renamed_path = '$NEW_PATHWithoutQuotes',is_renamed = true, dar_resolution_x = '$NEW_RESOLUTIONX', last_renamed_date = '$NOW', resolution_naming = '$AddResolutionNaming', title_checker = title, new_filename = '$NEW_FILENAME', old_filename = '$OLD_FILENAME', vr_new_path = '$VR_NEW_PATH_DQ', lib_path = '$LIB_PATH' FROM movie WHERE movie.mapper_id=video_file.mapper_id and video_file.id= '$DB_ID';"
									# DEBUG
									if [ -e "$VR_VideoStation_Folder/debug" ];
										then
											echo "$(date +"%F %T") : Function_Check_And_Rename : DB updated : movie" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
									fi
								else
									${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET path = '$NEW_PATHWithoutQuotes',old_path = '$DB_OLD_PATH',renamed_path = '$NEW_PATHWithoutQuotes',is_renamed = true, dar_resolution_x = '$NEW_RESOLUTIONX', last_renamed_date = '$NOW', resolution_naming = '$AddResolutionNaming', title_checker = tag_line, new_filename = '$NEW_FILENAME', old_filename = '$OLD_FILENAME', vr_new_path = '$VR_NEW_PATH_DQ', lib_path = '$LIB_PATH' FROM tvshow_episode WHERE tvshow_episode.mapper_id=video_file.mapper_id and video_file.id= '$DB_ID';"
									# DEBUG
									if [ -e "$VR_VideoStation_Folder/debug" ];
										then
											echo "$(date +"%F %T") : Function_Check_And_Rename : DB updated : tvshow" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
									fi
							fi
							

							CorrectVideoName="0"
							Function_Check_Both_Log_Have_Date
							Function_Check_Log_Date
							echo "Old path : $DOSSIER/" >>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
							echo "Old filename : "$OLD_NAME.$EXTENSION >>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
							echo "New path : $VR_NEW_PATH/" >>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
							echo "New filename : "$NEW_NAME.$EXTENSION >>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
							echo "DB_ID :" $DB_ID >>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
							echo "------" >>"${VR_APP_LOG_PATH}/$VideoLogName.tmp.log"
							synoindex -a "$NEW_PATH.$EXTENSION"
							NotCorrectVideoNameLogHasDate="1"
							let "VideoNbr++"
							#echo "$VideoNbr" >>/volume1/video/count.log
						else
							echo "error renaming $CHEMIN" to "$NEW_PATH.$EXTENSION" >>"${VR_APP_LOG_PATH}/$ErrorLogName.log"
							echo "file unchanged" >>"${VR_APP_LOG_PATH}/$ErrorLogName.log"
							echo "DB_ID :" $DB_ID >>"${VR_APP_LOG_PATH}/$ErrorLogName.log"
							OldNameLengh=$(echo -n "$OLD_NAME.$EXTENSION" | wc -m)
							NewNameLengh=$(echo -n "$NEW_NAME.$EXTENSION" | wc -m)
							if [[ "$OldNameLengh" -gt "143" ]] || [[ "$NewNameLengh" -gt "143" ]];
								then
									echo "old file lengh $OldNameLengh - new file lengh $NewNameLengh" >>"${VR_APP_LOG_PATH}/$ErrorLogName.log"
									echo "Too many characters. Please change path." >>"${VR_APP_LOG_PATH}/$ErrorLogName.log"
							fi
							echo "MV error code $MVErrorCode" >>"${VR_APP_LOG_PATH}/$ErrorLogName.log"
							echo "------" >>"${VR_APP_LOG_PATH}/$ErrorLogName.log"
					fi
			fi
	fi
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_Check_And_Rename : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Function_New_Filename_Layout () {
	###########################################################################################
	#    get info in conf file for new filename layout   #
	###########################################################################################
	if [ "$EnableAddYear" == "1" ] && [[ "$YEAR" -gt "0" ]]; #adds year in filename
		then 
			if [ "$IsItATVShow" == "1" ] && [ ! -z "$SERIE_ORIGINAL_DATE" ]; # adds year in movie file or original year in tvshow file
				then 
					AddYear=" (${SERIE_ORIGINAL_DATE})"
				else
					AddYear=" (${YEAR})"
			fi
		else
			AddYear=""
	fi
	if [ "$EnableAddResolutionNaming" == "1" ]; #adds common resolution name in filename
		then
			if [ -z "$DB_RESOLUTION_NAMING" ] || [ ! -e "$VR_APP_TMP_PATH/rescan" ];
				then
					Function_SAR_And_DAR
					
					if [[ "$NEW_RESOLUTIONX" -le "640" ]];
						then
							AddResolutionNaming="SD"
					fi
					if [[ "$NEW_RESOLUTIONX" -gt "640" ]] && [[ "$NEW_RESOLUTIONX" -le "1024" ]];
						then
							AddResolutionNaming="480p"
					fi
					if [[ "$NEW_RESOLUTIONX" -gt "1024" ]] && [[ "$NEW_RESOLUTIONX" -le "1280" ]];
						then
							AddResolutionNaming="720p"
					fi
					if [[ "$NEW_RESOLUTIONX" -gt "1280" ]] && [[ "$NEW_RESOLUTIONX" -le "1920" ]];
						then
							AddResolutionNaming="1080p"
					fi
					if [[ "$NEW_RESOLUTIONX" -gt "1920" ]];
						then
							AddResolutionNaming="4K"
					fi
				else
					AddResolutionNaming="$DB_RESOLUTION_NAMING"
			fi
			AAddResolutionNaming=" - $AddResolutionNaming"
		else
			AAddResolutionNaming=""
	fi
	if [ "$EnableAddResolution" == "1" ]; # adds resolution in filename
		then 
			AddResolution=" - ${RESOLUTIONX}x$RESOLUTIONY"
		else
			AddResolution=""
	fi
	if [ "$EnableAddCodecs" == "1" ]; # adds codec in filename
		then 
			AddCodecs=" - ${VIDEO_CODEC}-$AUDIO_CODEC"
		else
			AddCodecs=""
	fi
	if [ "$IsItATVShow" == "1" ]; # adds Season and episode in filename
		then 
			if [[ "$SEASON" -ge "0" ]] && [[ "$SEASON" -le "9" ]]; # add 0 before season number
				then 
					SEASON="0$SEASON"
			fi
			if [[ "$EPISODE" -ge "0" ]] && [[ "$EPISODE" -le "9" ]]; # add 0 before episode number
				then 
					EPISODE="0$EPISODE"
			fi
			AddSeasonEpisode=" S${SEASON}E${EPISODE}"
			if [ "$EnableAddYear" == "1" ]; # adds "-" if date is added in filename
				then 
					EpisodeName=" - $EPISODE_NAME -"
				else
					EpisodeName=" - $EPISODE_NAME"
			fi
			if [ -z "$EPISODE_NAME" ];
				then
					EpisodeName=""
			fi
		else
			AddSeasonEpisode=""
			EpisodeName=""
	fi
	
	
	###########################################################################################
	#    new filename layout   #
	###########################################################################################
	
	NewFilenameLayout="$TITRE$AddSeasonEpisode$EpisodeName$AddYear$AAddResolutionNaming$AddResolution$AddCodecs"
	
	#check if filename small enought to be moved
	NewFilenameLengh=$(echo -n "$NewFilenameLayout.$EXTENSION.$MaxExtensionLengh" | wc -m)
	if [[ "$NewFilenameLengh" -gt "143" ]];
		then
			NewFilenameLayout="$TITRE$AddSeasonEpisode$EpisodeName$AddYear$AAddResolutionNaming$AddResolution"
	fi
	NewFilenameLengh=$(echo -n "$NewFilenameLayout.$EXTENSION.$MaxExtensionLengh" | wc -m)
	if [[ "$NewFilenameLengh" -gt "143" ]];
		then
			NewFilenameLayout="$TITRE$AddSeasonEpisode$EpisodeName$AddYear$AAddResolutionNaming"
	fi
	NewFilenameLengh=$(echo -n "$NewFilenameLayout.$EXTENSION.$MaxExtensionLengh" | wc -m)
	if [[ "$NewFilenameLengh" -gt "143" ]];
		then
	NewFilenameLayout="$TITRE$AddSeasonEpisode$EpisodeName$AddYear"
	fi
		NewFilenameLengh=$(echo -n "$NewFilenameLayout.$EXTENSION.$MaxExtensionLengh" | wc -m)
	if [[ "$NewFilenameLengh" -gt "143" ]];
		then
	NewFilenameLayout="$TITRE$AddSeasonEpisode$AddYear"
	fi
	
	#to display all characters
	#echo "$NewFilenameLayout" | cat -v
	
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_New_Filename_Layout : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Function_SAR_And_DAR () {
	if [ -z "$DB_DAR_RESOLUTION_X" ] || [ ! -e "$VR_APP_TMP_PATH/rescan" ];
		then
			DAR=$(ffmpeg -i "$DOSSIER/$OLD_NAME.$EXTENSION" -hide_banner 2>&1 | grep -a -oP "DAR [0-9]+:[0-9]+")
			#SAR=$(ffmpeg -i "$DOSSIER/$OLD_NAME.$EXTENSION" -hide_banner 2>&1 | grep -i -oP "SAR [0-9]+:[0-9]+")
			
			# if DAR not exist set it to 1
			if [ -z "$DAR" ];
				then 
					DAR="DAR 1:1"
			fi &&
			
			# if multiple DAR
			DAR=$(for((n=1;n<$(echo $DAR | sed "s/ /\n/g" | wc -l)+1;n+=2)); do echo $DAR | cut -d' ' -f$n,$(($n + 1)); done | awk -F'[ :]' '{printf "%s %s:%s;%s\n",$1,$2,$3,$2/$3}' | sort -t';' -k2 --numeric-sort | tail -n1 | cut -d';' -f1) &&
			
			# DEBUG
			if [ -e "$VR_VideoStation_Folder/debug" ];
				then
					echo "$(date +"%F %T") : Function_SAR_And_DAR : DAR : $DAR" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			fi
	
			#get X and Y DAR
			X_DAR=$(echo "${DAR:4}" | cut -d: -f1) &&
			Y_DAR=$(echo "${DAR:4}" | cut -d: -f2) &&
			
			#get the new resolution
			NEW_RESOLUTIONX="$(($RESOLUTIONY*$X_DAR/$Y_DAR))"
			#get it in a whole number
			NEW_RESOLUTIONX=$(sed 's/.* \([0-9]\{1,\}\)\([0-9\.]\{0,\}\) .*/\1/g' <<< "${NEW_RESOLUTIONX}")
			
			#check resolution size
			if [[ "$NEW_RESOLUTIONX" -lt "$RESOLUTIONX" ]];
				then
					NEW_RESOLUTIONX="$RESOLUTIONX"
			fi
		else
			NEW_RESOLUTIONX="$DB_DAR_RESOLUTION_X"
	fi
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_SAR_And_DAR : NEW_RESOLUTIONX : $NEW_RESOLUTIONX : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Function_Do_All () {
	# check Kill switch
	if [ -e "${KillSwitchPath}stop" ];
		then 
			Function_Stop_Script
	fi
	Function_Get_Video_Info
	
	#if [ ! -z "$DB_ID" ] && ([ "$DB_RENAMED_PATH" != "$CHEMIN" ] || [ -e "$VR_APP_TMP_PATH/rescan" ]);
	if [ ! -z "$DB_ID" ] || [ -e "$VR_APP_TMP_PATH/rescan" ];
		then
			Function_New_Filename_Layout
			Function_Filename_Cleaning
			Function_Check_And_Rename
	fi
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_Do_All : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Function_show_time () {
	num=$1
	min=0
	hour=0
	day=0
	if((num>59));then
		((sec=num%60))
		((num=num/60))
		if((num>59));then
			((min=num%60))
			((num=num/60))
			if((num>23));then
				((hour=num%24))
				((day=num/24))
			else
				((hour=num))
			fi
		else
			((min=num))
		fi
	else
		((sec=num))
	fi
	DURATION="${sec}s"
	if (($min>0));then
		DURATION="${min}m $DURATION"
	fi
	if (($hour>0));then
		DURATION="${hour}h $DURATION"
	fi
	if (($day>0));then
		DURATION="${day}d $DURATION"
	fi
	echo $DURATION
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_show_time : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Function_Start_Script () {
	echo >> "$VR_APP_TMP_PATH/START"
	START_TIME=`date +%s`
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_Start_Script : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Function_Stop_Script () {
	if [ -e "$VR_APP_TMP_PATH/START" ];
		then 
			mv "$VR_APP_TMP_PATH/START" "$VR_APP_TMP_PATH/END"
			END_TIME=`date +%s`
			echo "Duration: " $(Function_show_time $(($END_TIME - $START_TIME))) >> "$VR_APP_TMP_PATH/END"
	fi
	. "${APP_TARGET_PATH}/scripts/resume.sh" &&
	. "${APP_TARGET_PATH}/scripts/sendnotification.sh" &&
	if [ -e "${VR_APP_LOG_PATH}/VideoRenamed.tmp.log" ];
		then
			cat "${VR_APP_LOG_PATH}/VideoRenamed.tmp.log" >> "${VR_APP_LOG_PATH}/VideoRenamed.log" &&
			rm "${VR_APP_LOG_PATH}/VideoRenamed.tmp.log"
	fi
	if [ -e "$VR_APP_TMP_PATH/rescan" ];
		then
			rm "$VR_APP_TMP_PATH/rescan"
	fi
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Function_Stop_Script : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
exit
}

###########################################################################################
#                      Declaration de la fonction de renommage                            #
###########################################################################################
Start_Rename_Movie () {
IsItAMovie="1"
###########################################################################################
#                   Recuperation des infos DB et mise en variable                         #
###########################################################################################
#${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'select c.is_renamed,c.renamed_path,c.old_path,c.dar_resolution_x,c.last_renamed_date,c.resolution_naming,c.id,a.title,c.path,a.year,c.resolutionx,c.resolutiony,c.video_codec,c.audio_codec,b.summary from movie a, summary b, video_file c where c.mapper_id=a.mapper_id and c.mapper_id=b.mapper_id and (c.renamed_path!=c.path OR c.renamed_path IS NULL) order by a.title desc;'" | while read ENTRY 

# check script duration
if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		echo "$(date +"%F %T") : Start_Rename_Movie : ---------------" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
		echo "$(date +"%F %T") : Start_Rename_Movie : DEBUT execution" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
fi
ExecSqlCommand "select c.is_renamed,c.renamed_path,c.old_path,c.dar_resolution_x,c.last_renamed_date,c.resolution_naming,c.new_filename,c.old_filename,c.vr_old_path,c.vr_new_path,c.id,a.title,c.path,a.year,c.resolutionx,c.resolutiony,c.video_codec,c.audio_codec,b.summary from movie a, summary b, video_file c where c.mapper_id=a.mapper_id and c.mapper_id=b.mapper_id and (c.new_filename!=(SELECT RIGHT(path, POSITION('/' in REVERSE(path)) -1 )) OR c.new_filename IS NULL OR c.path LIKE '%- ' || c.id || '.%' OR is_renamed = false OR c.title_checker !=a.title OR (c.title_checker = '') IS NOT FALSE OR (c.vr_new_path = '') IS NOT FALSE) order by a.title desc;" | while read ENTRY 
	do
		#SUMMARY recuperer ici car different entre film et tvshow
		SUMMARY="$(echo $ENTRY|cut -f19 -s -d"|")"
		Function_Do_All
		#delete empty folder
		if ([[ -e "$VR_OLD_PATH" ]] && [[ -z "$(ls -A "$VR_OLD_PATH")" ]]) || ([[ -e "$VR_OLD_PATH/@eaDir" ]] && [[ "$(ls "$VR_OLD_PATH" | wc -l)" -eq "1" ]]);
			then
				rm -rf "$VR_OLD_PATH"
				rmerr=$?
				if [ -e "$VR_VideoStation_Folder/debug" ];
					then
						if [[ "$rmerr" -eq "0" ]];
							then
								echo "$(date +"%F %T") : Start_Rename_Movie : deleting folder succeded" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
							else
								echo "$(date +"%F %T") : Start_Rename_Movie : deleting folder failed with error : $rmerr to delete :">>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								echo "$(date +"%F %T") : Start_Rename_Movie : $VR_OLD_PATH" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
						fi
				fi
				if [[ -z "$(ls -A "$(echo $(dirname "$VR_OLD_PATH"))")" ]];
					then 
						rm -rf "$(dirname "$VR_OLD_PATH")"
						rmerr=$?
						if [ -e "$VR_VideoStation_Folder/debug" ];
							then
								if [[ "$rmerr" -eq "0" ]];
									then
										echo "$(date +"%F %T") : Start_Rename_Movie : deleting folder succeded" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
									else
										echo "$(date +"%F %T") : Start_Rename_Movie : deleting folder failed with error : $rmerr to delete :">>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
										echo "$(date +"%F %T") : Start_Rename_Movie : $(dirname "$VR_OLD_PATH")" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
								fi
						fi
				fi
				if [ -e "$VR_VideoStation_Folder/debug" ];
					then
						echo "$(date +"%F %T") : Start_Rename_Movie : VR_OLD_PATH : $VR_OLD_PATH deleted" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
				fi
		fi
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				echo "$(date +"%F %T") : Start_Rename_Movie : VideoNbr : $VideoNbr" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
				echo "----------------------------------------------" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
		fi
		echo "$VideoNbr" > "$VR_APP_TMP_PATH/movienbr"
	done
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Start_Rename_Movie : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			# check script duration
			echo "$(date +"%F %T") : Start_Rename_Movie : FIN execution" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Start_Rename_Movie : -----" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Start_Rename_Movie : -----" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

Start_Rename_TVShow () {
IsItATVShow="1"
###########################################################################################
#                   Recuperation des infos DB et mise en variable                         #
###########################################################################################
#${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'select c.is_renamed,c.renamed_path,c.old_path,c.dar_resolution_x,c.last_renamed_date,c.resolution_naming,c.id,a.title,c.path,a.year,c.resolutionx,c.resolutiony,c.video_codec,c.audio_codec,b.summary,d.season,d.episode,d.tag_line,d.originally_available from tvshow a, summary b, video_file c, tvshow_episode d where a.id=d.tvshow_id and c.mapper_id=d.mapper_id and c.mapper_id=b.mapper_id and (c.renamed_path!=c.path OR c.renamed_path IS NULL) order by a.title desc;'" | while read ENTRY 

# check script duration
if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		echo "$(date +"%F %T") : Start_Rename_TVShow : ---------------" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
		echo "$(date +"%F %T") : Start_Rename_TVShow : DEBUT execution" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
fi
ExecSqlCommand "select c.is_renamed,c.renamed_path,c.old_path,c.dar_resolution_x,c.last_renamed_date,c.resolution_naming,c.new_filename,c.old_filename,c.vr_old_path,c.vr_new_path,c.id,a.title,c.path,a.year,c.resolutionx,c.resolutiony,c.video_codec,c.audio_codec,d.season,d.episode,d.tag_line,d.originally_available,b.summary from tvshow a, summary b, video_file c, tvshow_episode d where a.id=d.tvshow_id and c.mapper_id=d.mapper_id and c.mapper_id=b.mapper_id AND (c.new_filename!=(SELECT RIGHT(path, POSITION('/' in REVERSE(path)) -1 )) OR c.new_filename IS NULL OR c.path LIKE '%- ' || c.id || '.%' OR is_renamed = false OR c.title_checker !=d.tag_line OR ((c.title_checker = '') IS NOT FALSE AND (d.tag_line = '') IS FALSE) OR (c.vr_new_path = '') IS NOT FALSE AND d.season IS NOT NULL AND d.episode IS NOT NULL) order by a.title desc;" | while read ENTRY 
	do
		#SUMMARY recuperer ici car different entre film et tvshow
		SUMMARY="$(echo $ENTRY|cut -f23 -s -d"|")"
		Function_Do_All
		#delete empty folder
		if ([[ -e "$VR_OLD_PATH" ]] && [[ -z "$(ls -A "$VR_OLD_PATH")" ]]) || ([[ -e "$VR_OLD_PATH/@eaDir" ]] && [[ "$(ls "$VR_OLD_PATH" | wc -l)" -eq "1" ]]);
			then
				rm -rf "$VR_OLD_PATH"
				if [[ -z "$(ls -A "$(echo $(dirname "$VR_OLD_PATH"))")" ]];
					then 
						rm -rf "$(dirname "$VR_OLD_PATH")"
				fi
				if [ -e "$VR_VideoStation_Folder/debug" ];
					then
						echo "$(date +"%F %T") : Start_Rename_TVShow : VR_OLD_PATH : $VR_OLD_PATH deleted" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
				fi
		fi
		if [ -e "$VR_VideoStation_Folder/debug" ];
			then
				echo "$(date +"%F %T") : Start_Rename_TVShow : VideoNbr : $VideoNbr" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
				echo "----------------------------------------------" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
		fi
		echo "$VideoNbr" > "$VR_APP_TMP_PATH/tvshownbr"
	done
	# DEBUG
	if [ -e "$VR_VideoStation_Folder/debug" ];
		then
			echo "$(date +"%F %T") : Start_Rename_TVShow : passed" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			# check script duration
			echo "$(date +"%F %T") : Start_Rename_TVShow : FIN execution" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Start_Rename_TVShow : -----" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
			echo "$(date +"%F %T") : Start_Rename_TVShow : -----" >>"$VR_VideoStation_Folder/VideoRenamer/log/videorenamer.sh.log"
	fi
}

###########################################################################################
#                               Main run                             #
###########################################################################################
Function_Reset_Var
Function_Start_Script
#SUCMD=""
Start_Rename_TVShow && 
Function_Reset_Var &&
Start_Rename_Movie && 
if [[ "$delemptyfolder" = "1" ]];
	then
		. $VR_APP_SCRIPTS_PATH/delemptyfolder.sh
fi
Function_Stop_Script
