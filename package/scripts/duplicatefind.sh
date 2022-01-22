#!/bin/bash
# duplicatefind.sh


if [ -z "$VR_Var" ];
	then
		APP_TARGET_PATH="/var/packages/VideoRenamer/target"
		. ${APP_TARGET_PATH}/scripts/var.sh
fi




VR_APP_LOG_PATH="/volume1/Links/Dev"
ExecSqlCommand "SELECT * FROM movie a WHERE ((SELECT REGEXP_REPLACE(a.title,'[^a-zA-Z]+','','g')) LIKE (SELECT REGEXP_REPLACE(b.title,'[^a-zA-Z]+','','g')));" | while read ENTRY 
	do
		if [ ! -z "$ENTRY" ];
			then
				echo $ENTRY|cut -f1 -s -d"|" >> "$VR_APP_LOG_PATH/duplicatefind.log"
				echo "old path:" $ENTRY|cut -f2 -s -d"|" >> "$VR_APP_LOG_PATH/duplicatefind.log"
				echo "new path:" $ENTRY|cut -f3 -s -d"|" >> "$VR_APP_LOG_PATH/duplicatefind.log"
				echo "-----------" >> "$VR_APP_LOG_PATH/duplicatefind.log"
		fi
		
	done


#SELECT * FROM movie a WHERE (SELECT count(*) FROM movie b WHERE (SELECT REGEXP_REPLACE(a.title),'[^a-zA-Z]+','','g') LIKE (SELECT REGEXP_REPLACE(b.title),'[^a-zA-Z]+','','g')) > 1 

#ExecSqlCommand "SELECT * FROM movie a WHERE (SELECT count(*) FROM movie b WHERE ((SELECT REGEXP_REPLACE(a.title,'[^a-zA-Z]+','','g')) LIKE (SELECT REGEXP_REPLACE(b.title,'[^a-zA-Z]+','','g'))) > 1 );"

#select * from yourTable ou where (select count(*) from yourTable inr where inr.sid = ou.sid) > 1


#SELECT a.title FROM movie a, video_file b,video_file c WHERE a.mapper_id <> b.mapper_id AND c.mapper_id = b.mapper_id AND b.path=c.path;