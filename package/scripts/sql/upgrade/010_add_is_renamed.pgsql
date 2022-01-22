BEGIN;

ALTER TABLE video_file ADD COLUMN is_renamed boolean NOT NULL DEFAULT false;

COMMIT;