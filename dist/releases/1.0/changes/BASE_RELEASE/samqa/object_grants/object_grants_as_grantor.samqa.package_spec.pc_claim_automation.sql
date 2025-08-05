-- liquibase formatted sql
-- changeset SAMQA:1754373935942 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_claim_automation.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_claim_automation.sql:null:f15c402bd847d7bff133d8e2b8ea8a3274f2cd40:create

grant execute on samqa.pc_claim_automation to rl_sam_ro;

grant execute on samqa.pc_claim_automation to rl_sam_rw;

grant execute on samqa.pc_claim_automation to rl_sam1_ro;

grant debug on samqa.pc_claim_automation to sgali;

grant debug on samqa.pc_claim_automation to rl_sam_rw;

grant debug on samqa.pc_claim_automation to rl_sam1_ro;

grant debug on samqa.pc_claim_automation to rl_sam_ro;

