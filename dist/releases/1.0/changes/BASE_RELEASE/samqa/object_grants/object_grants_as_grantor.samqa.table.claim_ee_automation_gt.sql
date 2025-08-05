-- liquibase formatted sql
-- changeset SAMQA:1754373939326 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_ee_automation_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_ee_automation_gt.sql:null:8d10075f6a57c52a1a37a8338fb9aeb4f53854b7:create

grant delete on samqa.claim_ee_automation_gt to rl_sam_rw;

grant insert on samqa.claim_ee_automation_gt to rl_sam_rw;

grant select on samqa.claim_ee_automation_gt to rl_sam1_ro;

grant select on samqa.claim_ee_automation_gt to rl_sam_ro;

grant select on samqa.claim_ee_automation_gt to rl_sam_rw;

grant update on samqa.claim_ee_automation_gt to rl_sam_rw;

