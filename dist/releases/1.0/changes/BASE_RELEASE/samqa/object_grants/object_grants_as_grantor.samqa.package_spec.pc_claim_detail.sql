-- liquibase formatted sql
-- changeset SAMQA:1754373935950 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_claim_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_claim_detail.sql:null:a61c067632a054ee85985419a121a16f73b87681:create

grant execute on samqa.pc_claim_detail to rl_sam_ro;

grant execute on samqa.pc_claim_detail to rl_sam_rw;

grant execute on samqa.pc_claim_detail to rl_sam1_ro;

grant debug on samqa.pc_claim_detail to rl_sam_ro;

grant debug on samqa.pc_claim_detail to sgali;

grant debug on samqa.pc_claim_detail to rl_sam_rw;

grant debug on samqa.pc_claim_detail to rl_sam1_ro;

