-- liquibase formatted sql
-- changeset SAMQA:1754373941309 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.nacha_process_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.nacha_process_log.sql:null:099c6482c428406b154d6bf9a6258bbedd1b938a:create

grant delete on samqa.nacha_process_log to rl_sam_rw;

grant insert on samqa.nacha_process_log to rl_sam_rw;

grant select on samqa.nacha_process_log to rl_sam1_ro;

grant select on samqa.nacha_process_log to rl_sam_ro;

grant select on samqa.nacha_process_log to rl_sam_rw;

grant update on samqa.nacha_process_log to rl_sam_rw;

