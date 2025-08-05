-- liquibase formatted sql
-- changeset SAMQA:1754373935960 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_claim_interface.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_claim_interface.sql:null:814b0a8074fefd72cd39aeb7dd5abf103f5b9649:create

grant execute on samqa.pc_claim_interface to rl_sam_ro;

grant execute on samqa.pc_claim_interface to rl_sam_rw;

grant execute on samqa.pc_claim_interface to rl_sam1_ro;

grant debug on samqa.pc_claim_interface to rl_sam_ro;

grant debug on samqa.pc_claim_interface to sgali;

grant debug on samqa.pc_claim_interface to rl_sam_rw;

grant debug on samqa.pc_claim_interface to rl_sam1_ro;

