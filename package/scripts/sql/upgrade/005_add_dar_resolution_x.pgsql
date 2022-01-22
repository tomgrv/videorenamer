BEGIN;

ALTER TABLE video_file ADD COLUMN dar_resolution_x integer;

COMMIT;