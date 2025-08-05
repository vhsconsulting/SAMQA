-- liquibase formatted sql
-- changeset SAMQA:1754373940374 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.error_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.error_log.sql:null:712b73ddbf6300db607ce9493a5aa9f5f1ad96a9:create

grant delete on samqa.error_log to rl_sam_rw;

grant insert on samqa.error_log to rl_sam_rw;

grant select on samqa.error_log to rl_sam1_ro;

grant select on samqa.error_log to rl_sam_rw;

grant select on samqa.error_log to rl_sam_ro;

grant update on samqa.error_log to rl_sam_rw;

