BEGIN;

ALTER TABLE video_file ADD COLUMN title_checker varchar(255);

COMMIT;