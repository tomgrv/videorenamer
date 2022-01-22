#!/bin/bash
# logextraction.sh
LogExtraction="1"

if [ -z "$VR_Var" ];
	then
		APP_TARGET_PATH="/var/packages/VideoRenamer/target"
		. ${APP_TARGET_PATH}/scripts/var.sh
fi


# remove movie renamed number
if [ -e "$VR_VideoStation_Folder/VideoRenamer/log/logextraction.log" ];
	then
		rm -f "$VR_VideoStation_Folder/VideoRenamer/log/logextraction.log"
fi



#check number of movie
#ExecSqlCommand "SELECT COUNT(*) FROM video_file a, movie b WHERE last_renamed_date = '$NOW' AND a.mapper_id=b.mapper_id;"
ExecSqlCommand "select a.title,c.old_path,c.renamed_path from movie a, video_file c where c.mapper_id=a.mapper_id and c.last_renamed_date = (SELECT MAX(c.last_renamed_date) FROM video_file c) AND a.title IS NOT NULL order by a.title desc;" | while read ENTRY 
	do
		if [ ! -z "$ENTRY" ];
			then
				echo $ENTRY|cut -f1 -s -d"|" >> "$VR_VideoStation_Folder/VideoRenamer/log/logextraction.log"
				echo "old path:" $ENTRY|cut -f2 -s -d"|" >> "$VR_VideoStation_Folder/VideoRenamer/log/logextraction.log"
				echo "new path:" $ENTRY|cut -f3 -s -d"|" >> "$VR_VideoStation_Folder/VideoRenamer/log/logextraction.log"
				echo "-----------" >> "$VR_VideoStation_Folder/VideoRenamer/log/logextraction.log"
		fi
		
	done

#check number of TVShows
#ExecSqlCommand "select a.title,c.old_path,c.renamed_path from tvshow a, video_file c, tvshow_episode d where a.id=d.tvshow_id and c.mapper_id=a.mapper_id and c.last_renamed_date = (SELECT MAX(c.last_renamed_date) FROM video_file c) AND a.title IS NOT NULL order by a.title desc;" | while read ENTRY 
ExecSqlCommand "select a.title,c.old_path,c.renamed_path,d.tag_line from tvshow a, summary b, video_file c, tvshow_episode d where a.id=d.tvshow_id and c.mapper_id=d.mapper_id and c.mapper_id=b.mapper_id and c.last_renamed_date = (SELECT MAX(c.last_renamed_date) FROM video_file c) AND a.title IS NOT NULL order by a.title desc;" | while read ENTRY 
	do
		if [ ! -z "$ENTRY" ];
			then
				echo $ENTRY|cut -f1 -s -d"|" >> "$VR_VideoStation_Folder/VideoRenamer/log/logextraction.log"
				echo $ENTRY|cut -f4 -s -d"|" >> "$VR_VideoStation_Folder/VideoRenamer/log/logextraction.log"
				echo "old path:" $ENTRY|cut -f2 -s -d"|" >> "$VR_VideoStation_Folder/VideoRenamer/log/logextraction.log"
				echo "new path:" $ENTRY|cut -f3 -s -d"|" >> "$VR_VideoStation_Folder/VideoRenamer/log/logextraction.log"
				echo "-----------" >> "$VR_VideoStation_Folder/VideoRenamer/log/logextraction.log"
		fi
		
	done

	
	
	