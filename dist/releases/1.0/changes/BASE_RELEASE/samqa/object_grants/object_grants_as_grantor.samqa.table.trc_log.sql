-- liquibase formatted sql
-- changeset SAMQA:1754373942362 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.trc_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.trc_log.sql:null:c9e6882bd10dd9f48c983513e7e9c2fe353eadaf:create

grant delete on samqa.trc_log to rl_sam_rw;

grant insert on samqa.trc_log to rl_sam_rw;

grant select on samqa.trc_log to rl_sam1_ro;

grant select on samqa.trc_log to rl_sam_rw;

grant select on samqa.trc_log to rl_sam_ro;

grant update on samqa.trc_log to rl_sam_rw;

