BEGIN;

ALTER TABLE video_file ALTER COLUMN last_renamed_date TYPE VARCHAR(255);

COMMIT;