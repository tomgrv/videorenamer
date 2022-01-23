BEGIN;

ALTER TABLE video_file DROP COLUMN old_path;
ALTER TABLE video_file DROP COLUMN is_renamed;
ALTER TABLE video_file DROP COLUMN dar_resolution_x;
ALTER TABLE video_file DROP COLUMN last_renamed_date;
ALTER TABLE video_file DROP COLUMN renamed_path;
ALTER TABLE video_file DROP COLUMN resolution_naming;
ALTER TABLE video_file DROP COLUMN title_checker;
ALTER TABLE video_file DROP COLUMN new_filename;
ALTER TABLE video_file DROP COLUMN old_filename;
ALTER TABLE video_file DROP COLUMN vr_old_path;
ALTER TABLE video_file DROP COLUMN vr_new_path;
ALTER TABLE video_file DROP COLUMN lib_path;

COMMIT;