#!/bin/bash
# confchecker.sh

if [ -z "$VR_Var" ];
	then
		APP_TARGET_PATH="/var/packages/VideoRenamer/target"
		. ${APP_TARGET_PATH}/scripts/var.sh
fi





#does the conf file exist
if [ ! -e "$ConfFilePath" ]; 
	then 
		cp "$VR_APP_CFG_PATH/V.R.cfg" $ConfFilePath
		echo "$(date +"%F %T") : V.R.cfg copied to confFile" >> "/tmp/$PACKAGE_NAME/confchecker.sh.log"
		if [ -e "$VR_APP_LOG_PATH/START" ];
			then 
				rm -f "$VR_APP_LOG_PATH/START"
				echo "$(date +"%F %T") : START removed" >> "/tmp/$PACKAGE_NAME/confchecker.sh.log"
		fi
	else
		# call the conf file
		. $ConfFilePath
		if [[ -z "$MakeFolder" ]];
			then
				echo >> "$ConfFilePath"
				echo "# to sort your files in a corresponding folder set option to 1" >> "$ConfFilePath"
				echo "# folders will look like 'movietitle (year)'" >> "$ConfFilePath"
				echo "MakeFolder=0" >> "$ConfFilePath"
		fi
		if [[ -z "$CheckBoxEnableCycleRun" ]];
			then
				echo >> "$ConfFilePath"
				echo "# to run app every 6 hours set option to 1" >> "$ConfFilePath"
				echo "CheckBoxEnableCycleRun=0" >> "$ConfFilePath"
		fi
		if [[ -z "$movieyearfolder" ]];
			then
				echo >> "$ConfFilePath"
				echo "# to sort movie by decade (200x-201x-202x-...)" >> "$ConfFilePath"
				echo "movieyearfolder=0" >> "$ConfFilePath"
		fi
		if [[ -z "$tvshowyearfolder" ]];
			then
				echo >> "$ConfFilePath"
				echo "# to sort tvshows by decade (200x-201x-202x-...)" >> "$ConfFilePath"
				echo "tvshowyearfolder=0" >> "$ConfFilePath"
		fi
		if [[ -z "$delemptyfolder" ]];
			then
				echo >> "$ConfFilePath"
				echo "# to delete empty folders found in libraries" >> "$ConfFilePath"
				echo "delemptyfolder=0" >> "$ConfFilePath"
		fi
		if [ -z "$CheckBoxEnableMailNotification" ] || [ -z "$CheckBoxEnableDSMNotification" ];
			then 
				cp $ConfFilePath "/var/packages/$AppName/target/tmp/oldconf.cfg" &&
				cp "/var/packages/$AppName/target/cfg/V.R.cfg" $ConfFilePath &&
				#sed -i -e 's/EnableMailNotification=.*/EnableMailNotification='$EnableMailNotification'/g' "$ConfFilePath"
				#sed -i -e 's/EnableDSMNotification=.*/EnableDSMNotification='$EnableDSMNotification'/g' "$ConfFilePath"
				sed -i -e 's/EnableAddYear=.*/EnableAddYear='$EnableAddYear'/g' "$ConfFilePath"
				sed -i -e 's/EnableAddResolutionNaming=.*/EnableAddResolutionNaming='$EnableAddResolutionNaming'/g' "$ConfFilePath"
				sed -i -e 's/EnableAddResolution=.*/EnableAddResolution='$EnableAddResolution'/g' "$ConfFilePath"
				sed -i -e 's/EnableAddCodecs=.*/EnableAddCodecs='$EnableAddCodecs'/g' "$ConfFilePath"
				sed -i -e 's/DeleteNotAdvisedSpecialCharacters=.*/DeleteNotAdvisedSpecialCharacters='$DeleteNotAdvisedSpecialCharacters'/g' "$ConfFilePath"
				sed -i -e 's/DeleteSpecialLetters=.*/DeleteSpecialLetters='$DeleteSpecialLetters'/g' "$ConfFilePath"
				sed -i -e 's/DeleteAuthorizedSpecialCharacters=.*/DeleteAuthorizedSpecialCharacters='$DeleteAuthorizedSpecialCharacters'/g' "$ConfFilePath"
				sed -i -e 's/DeleteWhiteSpace=.*/DeleteWhiteSpace='$DeleteWhiteSpace'/g' "$ConfFilePath"
				sed -i -e 's/VideoNotRenamedLog=.*/VideoNotRenamedLog='$VideoNotRenamedLog'/g' "$ConfFilePath"
				sed -i -e 's/VideoRenamedLog=.*/VideoRenamedLog='$VideoRenamedLog'/g' "$ConfFilePath"
				sed -i -e 's/LogMaxSize=.*/LogMaxSize='$LogMaxSize'/g' "$ConfFilePath" 
				sed -i -e 's/MakeFolder=.*/MakeFolder='$MakeFolder'/g' "$ConfFilePath" 
				sed -i -e 's/CheckBoxEnableCycleRun=.*/CheckBoxEnableCycleRun='$CheckBoxEnableCycleRun'/g' "$ConfFilePath" 
				sed -i -e 's/movieyearfolder=.*/movieyearfolder='$movieyearfolder'/g' "$ConfFilePath" 
				sed -i -e 's/tvshowyearfolder=.*/tvshowyearfolder='$tvshowyearfolder'/g' "$ConfFilePath" 
				sed -i -e 's/delemptyfolder=.*/delemptyfolder='$delemptyfolder'/g' "$ConfFilePath" 
				
				synoacltool -enforce-inherit "$ConfFilePath"
				echo "$(date +"%F %T") : Conf file has been reset" >> "/tmp/$PACKAGE_NAME/confchecker.sh.log"
		fi
fi





