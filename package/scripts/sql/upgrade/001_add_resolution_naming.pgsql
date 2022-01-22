BEGIN;

ALTER TABLE video_file ADD COLUMN resolution_naming varchar(255);

COMMIT;