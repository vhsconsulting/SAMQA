-- liquibase formatted sql
-- changeset SAMQA:1754373938493 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ach_upload_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ach_upload_staging.sql:null:6d855c315a7619d9efa15c3e2d8134e33b811f42:create

grant delete on samqa.ach_upload_staging to rl_sam_rw;

grant insert on samqa.ach_upload_staging to rl_sam_rw;

grant select on samqa.ach_upload_staging to rl_sam1_ro;

grant select on samqa.ach_upload_staging to rl_sam_rw;

grant select on samqa.ach_upload_staging to rl_sam_ro;

grant update on samqa.ach_upload_staging to rl_sam_rw;

