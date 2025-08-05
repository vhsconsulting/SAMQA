-- liquibase formatted sql
-- changeset SAMQA:1754373940494 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.file_attachments_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.file_attachments_staging.sql:null:11cd93d2d3598217bbd73e4b41741de50b833ba0:create

grant delete on samqa.file_attachments_staging to rl_sam_rw;

grant insert on samqa.file_attachments_staging to rl_sam_rw;

grant select on samqa.file_attachments_staging to rl_sam1_ro;

grant select on samqa.file_attachments_staging to rl_sam_ro;

grant select on samqa.file_attachments_staging to rl_sam_rw;

grant update on samqa.file_attachments_staging to rl_sam_rw;

