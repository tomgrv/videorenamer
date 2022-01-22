BEGIN;

ALTER TABLE video_file ADD COLUMN last_renamed_date VARCHAR(255);

COMMIT;