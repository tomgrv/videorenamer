BEGIN;

ALTER TABLE video_file ADD COLUMN vr_old_path varchar(4096);
UPDATE video_file SET vr_old_path = (SELECT LEFT(path, (select length(path) - position('/' in reverse(path))+1) )) where vr_old_path IS NULL;
ALTER TABLE video_file ADD COLUMN vr_new_path varchar(4096);

COMMIT;