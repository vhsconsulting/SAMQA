-- liquibase formatted sql
-- changeset SAMQA:1754373936187 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_fin.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_fin.sql:null:abd9d79a493776f4b9ea64889231a9fc56b70606:create

grant execute on samqa.pc_fin to rl_sam_ro;

grant execute on samqa.pc_fin to rl_sam_rw;

grant execute on samqa.pc_fin to rl_sam1_ro;

grant debug on samqa.pc_fin to sgali;

grant debug on samqa.pc_fin to rl_sam_rw;

grant debug on samqa.pc_fin to rl_sam1_ro;

grant debug on samqa.pc_fin to rl_sam_ro;

