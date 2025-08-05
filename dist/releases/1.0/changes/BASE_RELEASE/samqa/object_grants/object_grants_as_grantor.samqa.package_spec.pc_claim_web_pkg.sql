-- liquibase formatted sql
-- changeset SAMQA:1754373935970 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_claim_web_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_claim_web_pkg.sql:null:293702053c7030a45951080788ef394de9e64f37:create

grant execute on samqa.pc_claim_web_pkg to rl_sam_ro;

grant execute on samqa.pc_claim_web_pkg to rl_sam_rw;

grant execute on samqa.pc_claim_web_pkg to rl_sam1_ro;

grant debug on samqa.pc_claim_web_pkg to sgali;

grant debug on samqa.pc_claim_web_pkg to rl_sam_rw;

grant debug on samqa.pc_claim_web_pkg to rl_sam1_ro;

grant debug on samqa.pc_claim_web_pkg to rl_sam_ro;

