#!/bin/ash
#resume.sh

if [ -z "$VR_Var" ];
	then
		APP_TARGET_PATH="/var/packages/VideoRenamer/target"
		. ${APP_TARGET_PATH}/scripts/var.sh
fi


rsync -av "$VR_APP_TMP_PATH/" "$VR_VideoStation_Folder/VideoRenamer/tmp/"
rsync -av "$VR_APP_LOG_PATH/" "$VR_VideoStation_Folder/VideoRenamer/log/"


rsync -av "$VR_APP_CFG_PATH/" "$VR_VideoStation_Folder/VideoRenamer/cfg/"
cp /etc/crontab "$VR_VideoStation_Folder/VideoRenamer/"


# copy db data
${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "COPY video_file TO '/tmp/VideoRenamer/video_file_db.csv' WITH DELIMITER '|' CSV HEADER;"
${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "COPY movie TO '/tmp/VideoRenamer/movie_db.csv' WITH DELIMITER '|' CSV HEADER;"
${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "COPY tvshow TO '/tmp/VideoRenamer/tvshow_db.csv' WITH DELIMITER '|' CSV HEADER;"
${PSQL} -U postgres -d ${VIDEO_METADATA_DB} -q -A -t -c "COPY tvshow_episode TO '/tmp/VideoRenamer/tvshow_episode_db.csv' WITH DELIMITER '|' CSV HEADER;"





find "/tmp/VideoRenamer/" -name \*.csv -exec cp {} "$VR_VideoStation_Folder/VideoRenamer/tmp/" \;
