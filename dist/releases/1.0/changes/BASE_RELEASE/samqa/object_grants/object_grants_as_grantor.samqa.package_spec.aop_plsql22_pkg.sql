-- liquibase formatted sql
-- changeset SAMQA:1754373935677 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.aop_plsql22_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.aop_plsql22_pkg.sql:null:1cfd85c1fcd955fe1d13817edb8400aff7ca1f3e:create

grant execute on samqa.aop_plsql22_pkg to rl_sam1_ro;

grant execute on samqa.aop_plsql22_pkg to rl_sam_rw;

grant execute on samqa.aop_plsql22_pkg to rl_sam_ro;

grant debug on samqa.aop_plsql22_pkg to rl_sam_ro;

grant debug on samqa.aop_plsql22_pkg to rl_sam1_ro;

grant debug on samqa.aop_plsql22_pkg to rl_sam_rw;

