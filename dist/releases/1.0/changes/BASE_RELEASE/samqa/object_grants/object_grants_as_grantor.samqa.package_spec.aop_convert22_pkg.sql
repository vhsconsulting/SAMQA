-- liquibase formatted sql
-- changeset SAMQA:1754373935646 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.aop_convert22_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.aop_convert22_pkg.sql:null:932b2f93977ad83f20119d4151f33dbaa873c834:create

grant execute on samqa.aop_convert22_pkg to rl_sam1_ro;

grant execute on samqa.aop_convert22_pkg to rl_sam_rw;

grant execute on samqa.aop_convert22_pkg to rl_sam_ro;

grant debug on samqa.aop_convert22_pkg to rl_sam_ro;

grant debug on samqa.aop_convert22_pkg to rl_sam1_ro;

grant debug on samqa.aop_convert22_pkg to rl_sam_rw;

