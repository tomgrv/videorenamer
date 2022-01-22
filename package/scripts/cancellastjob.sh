#!/bin/bash
# cancellastjob.sh

if [ -z "$VR_Var" ];
	then
		APP_TARGET_PATH="/var/packages/VideoRenamer/target"
		. ${APP_TARGET_PATH}/scripts/var.sh
fi


ExecSqlCommand "SELECT old_path,renamed_path,path,is_renamed,id,vr_old_path,old_filename,new_filename,vr_new_path FROM video_file WHERE last_renamed_date = (SELECT MAX(last_renamed_date) FROM video_file) AND path != old_path AND old_path IS NOT NULL;" | while read ENTRY 
	do
		DB_OLD_PATH="$(echo "$ENTRY"|cut -f1 -s -d"|")"
		#DB_OLD_PATH=$(echo $DB_OLD_PATH) il faut extraire le texte en gardans le double espace
		DB_RENAMED_PATH="$(echo "$ENTRY"|cut -f2 -s -d"|")"
		#DB_RENAMED_PATH=$(echo $DB_RENAMED_PATH) il faut extraire le texte en gardans le double espace
		DB_PATH="$(echo "$ENTRY"|cut -f3 -s -d"|")"
		#DB_PATH=$(echo $DB_PATH)
		DB_IS_RENAMED="$(echo "$ENTRY"|cut -f4 -s -d"|")"
		#DB_IS_RENAMED=$(echo $DB_IS_RENAMED)
		DB_ID="$(echo "$ENTRY"|cut -f5 -s -d"|")"
		#DB_ID=$(echo $DB_ID)
		VR_OLD_PATH="$(echo "$ENTRY"|cut -f6 -s -d"|")"
		#VR_OLD_PATH=$(echo $VR_OLD_PATH)
		OLD_FILENAME="$(echo "$ENTRY"|cut -f7 -s -d"|")"
		#OLD_FILENAME=$(echo $OLD_FILENAME)
		NEW_FILENAME="$(echo "$ENTRY"|cut -f8 -s -d"|")"
		#NEW_FILENAME=$(echo $NEW_FILENAME)
		VR_NEW_PATH="$(echo "$ENTRY"|cut -f9 -s -d"|")"
		EXTENSION="${NEW_FILENAME##*.}"
		NEW_FILENAME="${NEW_FILENAME%.*}"
		OLD_FILENAME="${OLD_FILENAME%.*}"
		
		if [[ ! -e "$VR_OLD_PATH" ]];
			then
				mkdir -p "$VR_OLD_PATH"
		fi
		if [ ! -z "$DB_ID" ];
			then
				# on renomme le vsmeta si il exist
					if [ -e "${VR_NEW_PATH}/$NEW_FILENAME.$EXTENSION.vsmeta" ];
						then
							mv "${VR_NEW_PATH}/$NEW_FILENAME.$EXTENSION.vsmeta" "$VR_OLD_PATH/$OLD_FILENAME.$EXTENSION.vsmeta"
							# DEBUG
							if [ -e "$VR_VideoStation_Folder/debug" ];
								then
									echo "$(date +"%F %T") : Function_Check_And_Rename : vsmeta moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
							fi
						elif [ -e "$VR_VideoStation_Folder/debug" ];
							then
								echo "$(date +"%F %T") : Function_Check_And_Rename : no vsmeta detected" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					fi
					# on renomme le ass si il exist
					ASS_Files=$(ls "${VR_NEW_PATH}/$NEW_FILENAME"*.ass 2> /dev/null | wc -l)
					if [[ "$ASS_Files" != "0" ]];
						then
							for subtitle in "${VR_NEW_PATH}/$NEW_FILENAME"*.ass; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$NEW_FILENAME}"
								mv "$subtitle" "$VR_OLD_PATH/$OLD_FILENAME - ${ifilename%.*}.ass"
								mverr=$(echo $?)
								if [[ "$mverr" -ne "0" ]] && [[ -e "$VR_VideoStation_Folder/debug" ]];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : ASS_Files : mv error : $mverr" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : ASS_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : ASS_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : ASS_Files : VR_OLD_PATH/OLD_FILENAME : $VR_OLD_PATH/$OLD_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : ASS_Files : VR_NEW_PATH/NEW_FILENAME : $VR_NEW_PATH/$NEW_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : ASS_Files : ass moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
								fi
							done
						elif [ -e "$VR_VideoStation_Folder/debug" ];
							then
								echo "$(date +"%F %T") : Function_Check_And_Rename : no ass detected" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					fi
					# on renomme le sami si il exist
					SAMI_Files=$(ls "${VR_NEW_PATH}/$NEW_FILENAME"*.sami 2> /dev/null | wc -l)
					if [[ "$SAMI_Files" != "0" ]];
						then
							for subtitle in "${VR_NEW_PATH}/$NEW_FILENAME"*.sami; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$NEW_FILENAME}"
								mv "$subtitle" "$VR_OLD_PATH/$OLD_FILENAME - ${ifilename%.*}.sami"
								mverr=$(echo $?)
								if [[ "$mverr" -ne "0" ]] && [[ -e "$VR_VideoStation_Folder/debug" ]];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SAMI_Files : mv error : $mverr" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SAMI_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SAMI_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SAMI_Files : VR_OLD_PATH/OLD_FILENAME : $VR_OLD_PATH/$OLD_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SAMI_Files : VR_NEW_PATH/NEW_FILENAME : $VR_NEW_PATH/$NEW_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SAMI_Files : ass moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
								fi
							done
						elif [ -e "$VR_VideoStation_Folder/debug" ];
							then
								echo "$(date +"%F %T") : Function_Check_And_Rename : no sami detected" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					fi
					# on renomme le smi si il exist
					SMI_Files=$(ls "${VR_NEW_PATH}/$NEW_FILENAME"*.smi 2> /dev/null | wc -l)
					if [[ "$SMI_Files" != "0" ]];
						then
							for subtitle in "${VR_NEW_PATH}/$NEW_FILENAME"*.smi; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$NEW_FILENAME}"
								mv "$subtitle" "$VR_OLD_PATH/$OLD_FILENAME - ${ifilename%.*}.smi"
								mverr=$(echo $?)
								if [[ "$mverr" -ne "0" ]] && [[ -e "$VR_VideoStation_Folder/debug" ]];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SMI_Files : mv error : $mverr" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SMI_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SMI_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SMI_Files : VR_OLD_PATH/OLD_FILENAME : $VR_OLD_PATH/$OLD_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SMI_Files : VR_NEW_PATH/NEW_FILENAME : $VR_NEW_PATH/$NEW_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SMI_Files : ass moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
								fi
							done
						elif [ -e "$VR_VideoStation_Folder/debug" ];
							then
								echo "$(date +"%F %T") : Function_Check_And_Rename : no smi detected" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					fi
					# on renomme le srt si il exist
					SRT_Files=$(ls "${VR_NEW_PATH}/$NEW_FILENAME"*.srt 2> /dev/null | wc -l)
					if [[ "$SRT_Files" != "0" ]];
						then
							for subtitle in "${VR_NEW_PATH}/$NEW_FILENAME"*.srt; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$NEW_FILENAME}"
								mv "$subtitle" "$VR_OLD_PATH/$OLD_FILENAME - ${ifilename%.*}.srt"
								mverr=$(echo $?)
								if [[ "$mverr" -ne "0" ]] && [[ -e "$VR_VideoStation_Folder/debug" ]];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SRT_Files : mv error : $mverr" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SRT_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SRT_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SRT_Files : VR_OLD_PATH/OLD_FILENAME : $VR_OLD_PATH/$OLD_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SRT_Files : VR_NEW_PATH/NEW_FILENAME : $VR_NEW_PATH/$NEW_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SRT_Files : ass moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
								fi
							done
						elif [ -e "$VR_VideoStation_Folder/debug" ];
							then
								echo "$(date +"%F %T") : Function_Check_And_Rename : no srt detected" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					fi
					# on renomme le ssa si il exist
					SSA_Files=$(ls "${VR_NEW_PATH}/$NEW_FILENAME"*.ssa 2> /dev/null | wc -l)
					if [[ "$SSA_Files" != "0" ]];
						then
							for subtitle in "${VR_NEW_PATH}/$NEW_FILENAME"*.ssa; do
								ifilename=$(basename -- "$subtitle")
								ifilename="${ifilename%.*}"
								ifilename="${ifilename//$NEW_FILENAME}"
								mv "$subtitle" "$VR_OLD_PATH/$OLD_FILENAME - ${ifilename%.*}.ssa"
								mverr=$(echo $?)
								if [[ "$mverr" -ne "0" ]] && [[ -e "$VR_VideoStation_Folder/debug" ]];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SSA_Files : mv error : $mverr" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
								fi
								# DEBUG
								if [ -e "$VR_VideoStation_Folder/debug" ];
									then
										echo "$(date +"%F %T") : Function_Check_And_Rename : SSA_Files : subtitle : $subtitle" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SSA_Files : ifilename : $ifilename" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SSA_Files : VR_OLD_PATH/OLD_FILENAME : $VR_OLD_PATH/$OLD_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SSA_Files : VR_NEW_PATH/NEW_FILENAME : $VR_NEW_PATH/$NEW_FILENAME" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
										echo "$(date +"%F %T") : Function_Check_And_Rename : SSA_Files : ass moved" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
								fi
							done
						elif [ -e "$VR_VideoStation_Folder/debug" ];
							then
								echo "$(date +"%F %T") : Function_Check_And_Rename : no ssa detected" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					fi
				
				#pour eviter les quotes dans la variable, il faut la doubler
				DB_OLD_PATH_WithoutQuotes=$(echo $DB_OLD_PATH |sed "s/'/''/g" )
				DB_RENAMED_PATH_WithoutQuotes=$(echo $DB_OLD_PATH |sed "s/'/''/g" )
				# On renomme le fichier
				mv "$VR_NEW_PATH/$NEW_FILENAME.$EXTENSION" "$VR_OLD_PATH/$OLD_FILENAME.$EXTENSION"
				CancelLastJobMVErrorCode=$(echo $?)
				if [ "$CancelLastJobMVErrorCode" -eq "0" ];
					then
						synoindex -d "$DB_RENAMED_PATH"
						
						# on met a jour la DB
						${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "UPDATE video_file SET path = (SELECT CONCAT(vr_old_path,'/',old_filename)),renamed_path = NULL,last_renamed_date = NULL,is_renamed = false WHERE id = '$DB_ID';"
						synoindex -a "$DB_OLD_PATH"
						#echo "$DB_OLD_PATH restored"
				fi
				
		fi
		
		# Debug part
		if [ -e "$VR_VideoStation_Folder/debug" ];
				then
					echo "$(date +"%F %T") : DB_OLD_PATH :" $DB_OLD_PATH >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					echo "$(date +"%F %T") : DB_RENAMED_PATH :" $DB_RENAMED_PATH >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					echo "$(date +"%F %T") : DB_PATH :" $DB_PATH >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					echo "$(date +"%F %T") : DB_IS_RENAMED :" $DB_IS_RENAMED >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					echo "$(date +"%F %T") : DB_ID :" $DB_ID >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					echo "$(date +"%F %T") : VR_OLD_PATH :" $VR_OLD_PATH >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					echo "$(date +"%F %T") : VR_NEW_PATH :" $VR_NEW_PATH >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					echo "$(date +"%F %T") : OLD_FILENAME :" $OLD_FILENAME >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					echo "$(date +"%F %T") : NEW_FILENAME :" $NEW_FILENAME >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					if [ "$CancelLastJobMVErrorCode" -eq "0" ];
						then
							echo "$(date +"%F %T") : file move OK" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
						else
							echo "$(date +"%F %T") : file move failed. error code :" $CancelLastJobMVErrorCode >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
					fi
					echo "------------------------------------" >>"$VR_VideoStation_Folder/VideoRenamer/log/cancellastjob.sh.log"
		fi
	done
