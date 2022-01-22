#!/bin/bash
# logextraction.sh

if [ -z "$VR_Var" ];
	then
		APP_TARGET_PATH="/var/packages/VideoRenamer/target"
		. ${APP_TARGET_PATH}/scripts/var.sh
fi


#list long movie title
#ExecSqlCommand "select title from movie where length(title) > 100"

#list long serie title and episode name
#ExecSqlCommand "select a.title from tvshow a , tvshow_episode b, video_file c where a.mapper_id=b.mapper_id and a.mapper_id=c.id and (select length (a.title || ' ' || b.tag_line) len) > 100"

# list path with more then 200 character
#ExecSqlCommand "select path from video_file where length(path) > 200"

#update is_renamed of all > 200 character
ExecSqlCommand "UPDATE video_file SET is_renamed = false WHERE length(path) > 200"