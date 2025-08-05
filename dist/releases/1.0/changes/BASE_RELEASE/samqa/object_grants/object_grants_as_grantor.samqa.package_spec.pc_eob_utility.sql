-- liquibase formatted sql
-- changeset SAMQA:1754373936149 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_eob_utility.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_eob_utility.sql:null:86cc99982f7986293a0a84a1ac04fbdd2dbd9baf:create

grant execute on samqa.pc_eob_utility to rl_sam_ro;

grant execute on samqa.pc_eob_utility to rl_sam_rw;

grant execute on samqa.pc_eob_utility to rl_sam1_ro;

grant debug on samqa.pc_eob_utility to sgali;

grant debug on samqa.pc_eob_utility to rl_sam_rw;

grant debug on samqa.pc_eob_utility to rl_sam1_ro;

grant debug on samqa.pc_eob_utility to rl_sam_ro;

