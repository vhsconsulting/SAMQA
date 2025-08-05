-- liquibase formatted sql
-- changeset SAMQA:1754373935637 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.aop_api22_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.aop_api22_pkg.sql:null:d7541cf17d22521166aec6062cdea50b002e5d25:create

grant execute on samqa.aop_api22_pkg to rl_sam1_ro;

grant execute on samqa.aop_api22_pkg to rl_sam_rw;

grant execute on samqa.aop_api22_pkg to rl_sam_ro;

grant debug on samqa.aop_api22_pkg to rl_sam_ro;

grant debug on samqa.aop_api22_pkg to rl_sam1_ro;

grant debug on samqa.aop_api22_pkg to rl_sam_rw;

