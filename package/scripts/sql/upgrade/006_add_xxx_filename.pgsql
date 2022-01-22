BEGIN;

ALTER TABLE video_file ADD COLUMN new_filename varchar(255);
ALTER TABLE video_file ADD COLUMN old_filename varchar(255);
UPDATE video_file SET old_filename = (SELECT RIGHT(path, POSITION('/' in REVERSE(path)) -1 )) where old_filename IS NULL;

COMMIT;