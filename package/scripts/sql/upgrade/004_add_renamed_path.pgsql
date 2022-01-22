BEGIN;

ALTER TABLE video_file ADD COLUMN renamed_path varchar(4096);

COMMIT;