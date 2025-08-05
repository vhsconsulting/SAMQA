-- liquibase formatted sql
-- changeset SAMQA:1754373939283 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_automation_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_automation_gt.sql:null:944143c02c2c02ac69c2e2120ff44abe75fa319f:create

grant delete on samqa.claim_automation_gt to rl_sam_rw;

grant insert on samqa.claim_automation_gt to rl_sam_rw;

grant select on samqa.claim_automation_gt to rl_sam1_ro;

grant select on samqa.claim_automation_gt to rl_sam_rw;

grant select on samqa.claim_automation_gt to rl_sam_ro;

grant update on samqa.claim_automation_gt to rl_sam_rw;

