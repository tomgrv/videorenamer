BEGIN;

ALTER TABLE video_file ADD COLUMN old_path varchar(4096);
ALTER TABLE video_file ADD COLUMN is_renamed boolean NOT NULL DEFAULT false;
ALTER TABLE video_file ADD COLUMN dar_resolution_x integer;
ALTER TABLE video_file ADD COLUMN last_renamed_date VARCHAR(255);
ALTER TABLE video_file ADD COLUMN renamed_path varchar(4096);
ALTER TABLE video_file ADD COLUMN title_checker varchar(255);
ALTER TABLE video_file ADD COLUMN resolution_naming varchar(255);
ALTER TABLE video_file ADD COLUMN new_filename varchar(255);
ALTER TABLE video_file ADD COLUMN old_filename varchar(255);
UPDATE video_file SET old_filename = (SELECT RIGHT(path, POSITION('/' in REVERSE(path)) -1 )) where old_filename IS NULL;
ALTER TABLE video_file ADD COLUMN vr_old_path varchar(4096);
UPDATE video_file SET vr_old_path = (SELECT LEFT(path, (select length(path) - position('/' in reverse(path))+1) )) where vr_old_path IS NULL;
ALTER TABLE video_file ADD COLUMN vr_new_path varchar(4096);

COMMIT;