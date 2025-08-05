-- liquibase formatted sql
-- changeset SAMQA:1754373936549 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_utility.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_utility.sql:null:2f4ae9eb317828093f4c9db80e395a89d3c9fabb:create

grant execute on samqa.pc_utility to rl_sam_ro;

grant execute on samqa.pc_utility to rl_sam_rw;

grant execute on samqa.pc_utility to public;

grant execute on samqa.pc_utility to rl_sam1_ro;

grant debug on samqa.pc_utility to rl_sam_ro;

grant debug on samqa.pc_utility to sgali;

grant debug on samqa.pc_utility to rl_sam_rw;

grant debug on samqa.pc_utility to rl_sam1_ro;

