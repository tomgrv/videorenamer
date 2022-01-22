#!/bin/ash
#resume.sh


if [ -z "$VR_Var" ];
	then
		APP_TARGET_PATH="/var/packages/VideoRenamer/target"
		. ${APP_TARGET_PATH}/scripts/var.sh
fi
# call the conf file
. ${VR_APP_CFG_PATH}/VideoRenamer.cfg

if [ -e "$VR_APP_TMP_PATH/resume" ];
	then
		rm -f "$VR_APP_TMP_PATH/resume"
fi

# get last action movie renamed number or set to 0
if [ -e "$VR_APP_TMP_PATH/movienbr" ]; 
	then
		LastMovieNbr="$(grep '' "$VR_APP_TMP_PATH/movienbr")"
	else
		LastMovieNbr="0"
fi
# get last action tvshow renamed number or set to 0
if [ -e "$VR_APP_TMP_PATH/tvshownbr" ];
	then
		LastTVShowNbr="$(grep '' "$VR_APP_TMP_PATH/tvshownbr")"
	else
		LastTVShowNbr="0"
fi

# DEBUG
if [ -e "$VR_VideoStation_Folder/debug" ];
	then
		echo "$(date +"%F %T") : CheckBoxEnableCycleRun : $CheckBoxEnableCycleRun" >>"$VR_VideoStation_Folder/VideoRenamer/log/resume.sh.log"
		echo "$(date +"%F %T") : LastMovieNbr : $LastMovieNbr" >>"$VR_VideoStation_Folder/VideoRenamer/log/resume.sh.log"
		echo "$(date +"%F %T") : LastTVShowNbr : $LastTVShowNbr" >>"$VR_VideoStation_Folder/VideoRenamer/log/resume.sh.log"
fi


# get last movie renamed number
if [[ "$LastMovieNbr" -gt "0" ]] && [[ "$CheckBoxEnableCycleRun" -eq "1" ]];
	then
		echo "Last renamed movies : $LastMovieNbr" >> "$VR_APP_TMP_PATH/resume"
fi
# get last tvshows renamed number
if [[ "$LastTVShowNbr" -gt "0" ]] && [[ "$CheckBoxEnableCycleRun" -eq "1" ]];
	then
		echo "Last renamed TVShows : $LastTVShowNbr" >> "$VR_APP_TMP_PATH/resume"
fi
# get movie renamed number
if [[ "$RenamedMovieNbr" -gt "0" ]];
	then
		echo "Daily renamed movies : $RenamedMovieNbr" >> "$VR_APP_TMP_PATH/resume"
fi

# get tvshow renamed number
if [[ "$CorruptedVideoNbr" -gt "0" ]];
	then
		echo "Corrupted videos: $CorruptedVideoNbr" >> "$VR_APP_TMP_PATH/resume"
fi

# get corrupted video number
if [[ "$RenamedTVShowNbr" -gt "0" ]];
	then
		echo "Daily renamed TV shows : $RenamedTVShowNbr" >> "$VR_APP_TMP_PATH/resume"
fi

#get start and end execution time
if [ -e "$VR_APP_TMP_PATH/END" ];
	then
		echo "$(grep '' "$VR_APP_TMP_PATH/END")" >> "$VR_APP_TMP_PATH/resume"
		#echo "starting time: $(date +"%H:%M:%S")" >> "$VR_APP_TMP_PATH/resume"
		#echo "End time: $(date +"%H:%M:%S")" >> "$VR_APP_TMP_PATH/resume"
		rm -f "$VR_APP_TMP_PATH/END"
fi

echo >> "$VR_APP_TMP_PATH/resume"


MovieNbr="$(${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'SELECT COUNT(DISTINCT id) FROM movie;'")"
if [ "$MovieNbr" -gt "0" ]; 
	then
		# Total movies
		echo "Total Movies: $MovieNbr" >> "$VR_APP_TMP_PATH/resume"

		# get the number of movie files
		MovieFileNbr="$(${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'SELECT COUNT(DISTINCT c.path) FROM movie a, video_file c where c.mapper_id=a.mapper_id;'")"
		echo "Total Movie files : $MovieFileNbr" >> "$VR_APP_TMP_PATH/resume"
fi

TVShowNbr="$(${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'SELECT COUNT(DISTINCT id) FROM tvshow;'")"
if [ "$TVShowNbr" -gt "0" ];
	then
		# total tvshows
		echo "Total TVShows : $TVShowNbr" >> "$VR_APP_TMP_PATH/resume"

		# get tvhow episode number
		TVShowEpisodeNbr="$(${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'SELECT COUNT(DISTINCT mapper_id) FROM tvshow_episode;'")"
		echo "Total TVShow episodes : $TVShowEpisodeNbr" >> "$VR_APP_TMP_PATH/resume"

		# get tvshow episode file number
		TVShowFileNbr="$(${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'SELECT COUNT(DISTINCT c.path) FROM tvshow_episode d, video_file c where c.mapper_id=d.mapper_id;'")"
		echo "Total TVShow files : $TVShowFileNbr" >> "$VR_APP_TMP_PATH/resume"
fi


# find duplicate files
#DuplicateMovieNbr="$(${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'select a.title from movie a where (select count(title) FROM movie b where a.title=b.title) > 1 order by title desc;'")"
#DuplicateMovieNbr="$(${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'select title,count(*) from movie group by title having count(*) > 1;'")"
#DuplicateMovieNbr="$(${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'select a.title,count(c.path) from movie a, video_file c group by title having count(c.path) > 1;'")"
#DuplicateMovieNbr="$(${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -q -A -t -c 'select path,count(*) from video_file group by path having count(*) > 1;'")"


#cp "$VR_APP_TMP_PATH/resume" "/volume$COUNTER/video/" 
