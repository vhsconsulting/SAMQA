-- liquibase formatted sql
-- changeset SAMQA:1754373936463 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_sam_search.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_sam_search.sql:null:6dff6452099014bb7215affa42b7786b2f8e5740:create

grant execute on samqa.pc_sam_search to rl_sam_rw;

grant execute on samqa.pc_sam_search to rl_sam1_ro;

grant execute on samqa.pc_sam_search to rl_sam_ro;

grant debug on samqa.pc_sam_search to rl_sam_rw;

grant debug on samqa.pc_sam_search to rl_sam1_ro;

grant debug on samqa.pc_sam_search to rl_sam_ro;

