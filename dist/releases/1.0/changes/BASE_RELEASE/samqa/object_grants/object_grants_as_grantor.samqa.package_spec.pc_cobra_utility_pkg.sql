-- liquibase formatted sql
-- changeset SAMQA:1754373935985 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_cobra_utility_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_cobra_utility_pkg.sql:null:e816cc577b31a0818448ab140fea3a36c4903ddb:create

grant execute on samqa.pc_cobra_utility_pkg to rl_sam_ro;

grant execute on samqa.pc_cobra_utility_pkg to rl_sam_rw;

grant execute on samqa.pc_cobra_utility_pkg to rl_sam1_ro;

grant debug on samqa.pc_cobra_utility_pkg to rl_sam_ro;

grant debug on samqa.pc_cobra_utility_pkg to sgali;

grant debug on samqa.pc_cobra_utility_pkg to rl_sam_rw;

grant debug on samqa.pc_cobra_utility_pkg to rl_sam1_ro;

