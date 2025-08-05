-- liquibase formatted sql
-- changeset SAMQA:1754373940503 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.file_upload_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.file_upload_history.sql:null:c0ba3f8e49da58c8bab0d2b724aeb81b6baadc45:create

grant delete on samqa.file_upload_history to rl_sam_rw;

grant insert on samqa.file_upload_history to rl_sam_rw;

grant select on samqa.file_upload_history to rl_sam1_ro;

grant select on samqa.file_upload_history to public;

grant select on samqa.file_upload_history to rl_sam_rw;

grant select on samqa.file_upload_history to rl_sam_ro;

grant update on samqa.file_upload_history to rl_sam_rw;

