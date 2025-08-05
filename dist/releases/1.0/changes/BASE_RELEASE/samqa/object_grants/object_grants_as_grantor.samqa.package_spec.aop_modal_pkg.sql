-- liquibase formatted sql
-- changeset SAMQA:1754373935668 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.aop_modal_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.aop_modal_pkg.sql:null:2a6e2321c330ef29f0b0fc689a1dafa068a14fb5:create

grant execute on samqa.aop_modal_pkg to rl_sam1_ro;

grant execute on samqa.aop_modal_pkg to rl_sam_rw;

grant execute on samqa.aop_modal_pkg to rl_sam_ro;

grant debug on samqa.aop_modal_pkg to rl_sam_ro;

grant debug on samqa.aop_modal_pkg to rl_sam1_ro;

grant debug on samqa.aop_modal_pkg to rl_sam_rw;

