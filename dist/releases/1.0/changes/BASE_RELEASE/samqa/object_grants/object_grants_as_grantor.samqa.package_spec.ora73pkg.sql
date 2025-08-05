-- liquibase formatted sql
-- changeset SAMQA:1754373935789 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.ora73pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.ora73pkg.sql:null:2c17805237c463b09ac0029b3363f34f64383018:create

grant execute on samqa.ora73pkg to rl_sam_ro;

grant execute on samqa.ora73pkg to rl_sam_rw;

grant execute on samqa.ora73pkg to rl_sam1_ro;

grant debug on samqa.ora73pkg to rl_sam_ro;

grant debug on samqa.ora73pkg to sgali;

grant debug on samqa.ora73pkg to rl_sam_rw;

grant debug on samqa.ora73pkg to rl_sam1_ro;

