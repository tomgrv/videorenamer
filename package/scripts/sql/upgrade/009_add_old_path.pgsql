BEGIN;

ALTER TABLE video_file ADD COLUMN old_path varchar(4096);

COMMIT;