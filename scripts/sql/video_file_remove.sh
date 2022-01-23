#!/bin/sh
# add sql tables for Video Renamer
VIDEO_METADATA_DB="video_metadata"

BASH_PATH="/bin/bash"
SU_VIDEO_STATION="/bin/su -l VideoStation -s ${BASH_PATH}"

PG_SCRIPT="/var/packages/VideoRenamer/scripts/video_file_remove.pgsql"
CREATE_DB="/usr/bin/createdb"
PSQL="/usr/bin/psql"



   ${SU_VIDEO_STATION} -c "${PSQL} -U VideoStation -d ${VIDEO_METADATA_DB} -f ${PG_SCRIPT}"
   if [ $? != 0 ]; then
      echo "Failed to remove tables in video_metadata database"
      exit
   fi











