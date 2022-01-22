BEGIN;

ALTER TABLE video_file ADD COLUMN lib_path varchar(4096);

COMMIT;