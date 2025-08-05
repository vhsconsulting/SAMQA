-- liquibase formatted sql
-- changeset SAMQA:1754373942052 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.scheduler_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.scheduler_details.sql:null:291710575bdfc173428857744970614900ef570a:create

grant delete on samqa.scheduler_details to rl_sam_rw;

grant insert on samqa.scheduler_details to rl_sam_rw;

grant select on samqa.scheduler_details to rl_sam1_ro;

grant select on samqa.scheduler_details to rl_sam_rw;

grant select on samqa.scheduler_details to rl_sam_ro;

grant update on samqa.scheduler_details to rl_sam_rw;

